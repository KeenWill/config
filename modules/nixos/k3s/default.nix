# Module for configuring k3s Kubernetes on NixOS
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.k3s;
in
{
  imports = [
    ./flux.nix
    ./sops.nix
    ./bootstrap.nix
    ./renovate.nix
  ];

  options.services.k3s = {
    enable = mkEnableOption "k3s lightweight Kubernetes";

    role = mkOption {
      type = types.enum [
        "server"
        "agent"
      ];
      default = "server";
      description = "Whether k3s should run as a server or agent";
    };

    serverAddr = mkOption {
      type = types.str;
      default = "";
      description = "The k3s server to connect to (required for agent role)";
    };

    tokenFile = mkOption {
      type = types.str;
      default = "";
      description = "File containing the k3s token to use when connecting to a server";
    };

    clusterInit = mkOption {
      type = types.bool;
      default = true;
      description = "Initialize HA cluster using an embedded etcd datastore";
    };

    disableComponents = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "traefik"
        "servicelb"
        "metrics-server"
      ];
      description = "List of built-in components to disable";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "--no-deploy=traefik"
        "--cluster-cidr=10.24.0.0/16"
      ];
      description = "Extra flags to pass to k3s";
    };
  };

  config = mkIf cfg.enable {
    # Install the required packages
    environment.systemPackages = with pkgs; [
      k3s
      kubectl
      kubernetes-helm
      fluxcd
    ];

    # Configure firewall for k3s
    networking.firewall = {
      allowedTCPPorts = mkMerge [
        (mkIf (cfg.role == "server") [ 6443 ]) # Kubernetes API
        [ 10250 ] # Kubelet API
      ];
      # UDP ports for flannel VXLAN
      allowedUDPPorts = [ 8472 ];
    };

    # k3s service configuration
    systemd.services.k3s = {
      description = "k3s - Lightweight Kubernetes";
      documentation = [ "https://k3s.io" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.k3s ];

      serviceConfig = {
        Type = "notify";
        KillMode = "process";
        Delegate = "yes";
        LimitNOFILE = "infinity";
        LimitNPROC = "infinity";
        LimitCORE = "infinity";
        TasksMax = "infinity";
        TimeoutStartSec = "0";
        Restart = "always";
        RestartSec = "5s";
      };

      script =
        let
          k3sCmd = if cfg.role == "server" then "server" else "agent";
          disableFlags = concatMapStrings (component: " --disable=${component}") cfg.disableComponents;
          extraFlagsStr = concatStringsSep " " cfg.extraFlags;
          serverAddrFlag = if cfg.role == "agent" then " --server ${cfg.serverAddr}" else "";
          tokenFileFlag = if cfg.tokenFile != "" then " --token-file ${cfg.tokenFile}" else "";
          clusterInitFlag = if cfg.role == "server" && cfg.clusterInit then " --cluster-init" else "";
        in
        ''
          exec ${pkgs.k3s}/bin/k3s ${k3sCmd}${disableFlags}${serverAddrFlag}${tokenFileFlag}${clusterInitFlag} ${extraFlagsStr}
        '';
    };

    # Ensure kubelet configuration
    services.k3s.extraFlags = [
      # Add extra configuration options as needed
      "--kube-controller-manager-arg=bind-address=0.0.0.0"
      "--kube-proxy-arg=metrics-bind-address=0.0.0.0"
      "--kube-scheduler-arg=bind-address=0.0.0.0"
    ];
  };
}
