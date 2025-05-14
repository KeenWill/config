# k3s Kubernetes configuration for wkg-server0
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/nixos/k3s/k3s-server.nix
  ];

  # Override any k3s settings as needed for this specific server
  services.k3s = {
    extraFlags = [
      "--tls-san=${config.networking.hostName}"
      "--tls-san=${config.networking.hostName}.local"
      "--tls-san=10.0.1.100" # Replace with your server's IP address
    ];
  };

  # Configure Flux GitOps
  services.fluxcd = {
    # Update this to point to your actual Git repository
    gitRepository = "https://github.com/williamgoeller/k3s-gitops.git";
  };

  # Configure SOPS for Kubernetes secrets
  sops = {
    # Set a specific SOPS configuration if needed
    # defaultSopsFile = "/etc/k3s/secrets.yaml";
  };

  # Enable k3s bootstrap
  k3s.bootstrap = {
    enable = true;
    script = ''
      # Add any server-specific bootstrap steps here
      echo "Configuring server-specific k3s settings..."

      # Example: Create a PersistentVolume for ZFS storage
      cat <<EOF > /var/lib/rancher/k3s/server/manifests/local-path-storage.yaml
      apiVersion: storage.k8s.io/v1
      kind: StorageClass
      metadata:
        name: local-path
        annotations:
          storageclass.kubernetes.io/is-default-class: "true"
      provisioner: rancher.io/local-path
      volumeBindingMode: WaitForFirstConsumer
      reclaimPolicy: Delete
      parameters:
        path: /tank/k3s/pv
      EOF

      # Example: Create a ConfigMap with system information
      cat <<EOF > /var/lib/rancher/k3s/server/manifests/system-info.yaml
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: system-info
        namespace: kube-system
      data:
        hostname: "$(hostname)"
        machine-id: "$(cat /etc/machine-id)"
        deployment-date: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      EOF
    '';
  };

  # Enable renovate for automated dependency updates
  services.renovate = {
    enable = true;
    gitRepository = "https://github.com/williamgoeller/k3s-gitops.git";
    # Configure GitHub token securely
    tokenFile = "/var/lib/renovate/github-token";
  };

  # Additional firewall rules specific to this server's k3s deployment
  networking.firewall = {
    allowedTCPPorts = [
      # Add any additional ports needed
    ];
  };

  # Create PersistentVolume storage directories
  systemd.tmpfiles.rules = [
    "d /tank/k3s/pv 0755 root root -"
    "d /tank/k3s/pv/data 0755 root root -"
    "d /tank/k3s/pv/config 0755 root root -"
    "d /tank/k3s/pv/backups 0755 root root -"
  ];
}
