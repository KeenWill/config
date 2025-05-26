# Flux GitOps configuration for k3s
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.k3s.fluxcd;
in
{
  options.k3s.fluxcd = {
    enable = mkEnableOption "Flux GitOps operator for K3s";

    gitRepository = mkOption {
      type = types.str;
      default = "";
      example = "https://github.com/username/gitops-repo.git";
      description = "URL of the Git repository to sync";
    };

    branch = mkOption {
      type = types.str;
      default = "main";
      description = "Branch of the Git repository to sync";
    };

    path = mkOption {
      type = types.str;
      default = "./kubernetes";
      description = "Path within the Git repository to sync";
    };

    interval = mkOption {
      type = types.str;
      default = "1m";
      example = "5m";
      description = "Sync interval";
    };

    deployKey = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to SSH private key for Git repository authentication";
    };
  };

  config = mkIf cfg.enable {
    # Install flux CLI tools
    environment.systemPackages = with pkgs; [
      fluxcd
    ];

    # Create flux bootstrap script
    environment.etc."k3s/flux-bootstrap.sh" = {
      mode = "0755";
      text = ''
        #!/bin/sh
        set -e

        # Wait for k3s to be ready
        echo "Waiting for k3s to be ready..."
        until kubectl get nodes; do
          sleep 5
        done

        # Check if Flux is already installed
        if kubectl get namespace flux-system >/dev/null 2>&1; then
          echo "Flux is already installed."
          exit 0
        fi

        # Prepare deployment key if specified
        ${optionalString (cfg.deployKey != null) ''
          DEPLOY_KEY=$(cat ${cfg.deployKey})
          kubectl create secret generic flux-system \
            --namespace=flux-system \
            --from-file=identity=${cfg.deployKey} \
            --dry-run=client -o yaml | kubectl apply -f -
        ''}

        # Bootstrap Flux
        echo "Bootstrapping Flux..."
        flux bootstrap git \
          --url=${cfg.gitRepository} \
          --branch=${cfg.branch} \
          --path=${cfg.path} \
          --interval=${cfg.interval} \
          ${optionalString (cfg.deployKey != null) "--ssh-key-algorithm=ed25519"}
          
        echo "Flux bootstrap complete!"
      '';
    };

    # Create a service to bootstrap Flux after k3s is running
    systemd.services.flux-bootstrap = {
      description = "Bootstrap Flux GitOps for k3s";
      wantedBy = [ "multi-user.target" ];
      after = [ "k3s.service" ];
      wants = [ "k3s.service" ];
      path = with pkgs; [
        kubectl
        kubernetes-helm
        fluxcd
      ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash /etc/k3s/flux-bootstrap.sh";
        Restart = "on-failure";
        RestartSec = "30s";
      };
    };
  };
}