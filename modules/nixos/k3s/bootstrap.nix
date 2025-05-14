# Bootstrap script for k3s cluster setup
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.k3s.bootstrap;
in
{
  options.k3s.bootstrap = {
    enable = mkEnableOption "k3s bootstrap scripts";

    script = mkOption {
      type = types.lines;
      default = "";
      description = "Custom bootstrap script content";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bash
    ];

    # Create bootstrap script
    environment.etc."k3s/bootstrap.sh" = {
      mode = "0755";
      text = ''
        #!/usr/bin/env bash
        set -e

        echo "Starting k3s bootstrap process..."

        # Wait for k3s to be fully up
        echo "Waiting for k3s to be ready..."
        until kubectl get nodes; do
          echo "Waiting for k3s API server to be available..."
          sleep 5
        done

        echo "k3s is ready!"

        # Create a directory for the bootstrap manifests
        MANIFESTS_DIR="/var/lib/rancher/k3s/server/manifests"
        mkdir -p "$MANIFESTS_DIR"

        # Apply default namespaces
        echo "Creating default namespaces..."
        cat <<EOF > "$MANIFESTS_DIR/namespaces.yaml"
        apiVersion: v1
        kind: Namespace
        metadata:
          name: monitoring
        ---
        apiVersion: v1
        kind: Namespace
        metadata:
          name: storage
        ---
        apiVersion: v1
        kind: Namespace
        metadata:
          name: apps
        EOF

        # Set up Cilium CNI if required
        if [ "${toString (elem "flannel" config.services.k3s.disableComponents)}" = "1" ]; then
          echo "Setting up Cilium CNI..."
          helm repo add cilium https://helm.cilium.io/
          helm install cilium cilium/cilium --namespace kube-system \
            --set ipam.mode=kubernetes \
            --set kubeProxyReplacement=strict \
            --set k8sServiceHost=$(hostname) \
            --set k8sServicePort=6443
        fi

        # Set up MetalLB if required
        if [ "${toString (elem "servicelb" config.services.k3s.disableComponents)}" = "1" ]; then
          echo "Setting up MetalLB load balancer..."
          helm repo add metallb https://metallb.github.io/metallb
          helm install metallb metallb/metallb --namespace metallb-system --create-namespace
          
          # Configure MetalLB address pool - replace with your actual network range
          cat <<EOF > "$MANIFESTS_DIR/metallb-config.yaml"
          apiVersion: metallb.io/v1beta1
          kind: IPAddressPool
          metadata:
            name: first-pool
            namespace: metallb-system
          spec:
            addresses:
            - 10.0.1.200-10.0.1.250
          ---
          apiVersion: metallb.io/v1beta1
          kind: L2Advertisement
          metadata:
            name: l2-advert
            namespace: metallb-system
          spec:
            ipAddressPools:
            - first-pool
          EOF
        fi

        # Set up ingress-nginx if required
        if [ "${toString (elem "traefik" config.services.k3s.disableComponents)}" = "1" ]; then
          echo "Setting up ingress-nginx..."
          helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
          helm install ingress-nginx ingress-nginx/ingress-nginx \
            --namespace ingress-nginx --create-namespace \
            --set controller.service.type=LoadBalancer
        fi

        # Custom script content
        ${cfg.script}

        echo "Bootstrap complete!"
      '';
    };

    # Create a service to run the bootstrap script
    systemd.services.k3s-bootstrap = {
      description = "Bootstrap k3s cluster components";
      wantedBy = [ "multi-user.target" ];
      after = [ "k3s.service" ];
      wants = [ "k3s.service" ];
      path = with pkgs; [
        kubectl
        kubernetes-helm
        jq
        curl
      ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash /etc/k3s/bootstrap.sh";
        Restart = "on-failure";
        RestartSec = "30s";
      };
    };
  };
}
