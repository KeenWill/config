# k3s server configuration with integrated Flux, SOPS, and other tools
{
  config,
  lib,
  pkgs,
  inputs ? {},
  ...
}:

with lib;

{
  imports = [
    ./default.nix
  ];

  # Enable k3s with server role
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--tls-san=${config.networking.hostName}"
      "--cluster-cidr=10.42.0.0/16"
      "--service-cidr=10.43.0.0/16"
      "--cluster-dns=10.43.0.10"
      "--flannel-backend=none"  # Disable flannel
      "--disable-network-policy" # Disable network policy controller
      "--disable=traefik"  # Disable traefik
      "--disable=servicelb"  # Disable servicelb
    ];
  };

  # Enable Flux GitOps
  k3s.fluxcd = {
    enable = true;
    # Default repository URL that can be overridden in machine-specific config
    gitRepository = mkDefault "https://github.com/yourusername/k3s-gitops.git";
    branch = mkDefault "main";
    path = mkDefault "./kubernetes";
    interval = mkDefault "1m";
    # deployKey = mkDefault null; # Uncomment and set if using SSH
  };

  # SOPS secrets management - defined via sops-nix import in the main configuration
  k3s.sops = {
    enable = true;
    age.generateKey = true;
    # If you have a sops config file, specify it here
    # defaultSopsFile = "/path/to/secrets.yaml";
  };

  # Ensure directories exist
  systemd.tmpfiles.rules = [
    # Rancher/k3s directories
    "d /var/lib/rancher 0755 root root -"
    "d /var/lib/rancher/k3s 0755 root root -"
    "d /var/lib/rancher/k3s/server 0755 root root -"
    "d /etc/rancher 0755 root root -"
    "d /etc/rancher/k3s 0755 root root -"
    # Kubernetes persistent volumes directory
    "d /var/lib/k3s-pv 0755 root root -"
  ];

  # Additional tools for working with Kubernetes
  environment.systemPackages = with pkgs; [
    # Kubernetes related tools
    k3s # Lightweight Kubernetes distribution
    kubectl # Kubernetes command-line tool
    kubernetes-helm # Kubernetes package manager
    fluxcd # GitOps tool for Kubernetes
    k9s # Terminal UI for Kubernetes
    kubectx # Tool for switching between Kubernetes contexts and namespaces
    stern # Multi-pod log tailing for Kubernetes
    kubeseal # Sealed Secrets encryption for Kubernetes
    kustomize # Kubernetes YAML customization tool

    # Security and secrets management
    sops # Secret management tool
    age # Modern encryption tool
    gnupg # GNU Privacy Guard

    # Development and utilities
    jq # JSON processor for scripting
    yq-go # YAML processor similar to jq
  ];

  # Open ports required for k3s and surrounding services
  networking.firewall = {
    allowedTCPPorts = [
      6443 # Kubernetes API
      80
      443 # HTTP/HTTPS
      8443 # Alternative HTTPS port
    ];
    allowedUDPPorts = [
      8472 # Flannel VXLAN
    ];
  };
}