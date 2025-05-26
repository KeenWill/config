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

  # This module extends the built-in k3s module
  # It doesn't redefine options but instead builds on top of the system k3s service
  config = mkIf cfg.enable {
    # Install the required packages
    environment.systemPackages = with pkgs; [
      k3s
      kubectl
      kubernetes-helm
    ];

    # Ensure directories exist
    systemd.tmpfiles.rules = [
      "d /var/lib/rancher 0755 root root -"
      "d /var/lib/rancher/k3s 0755 root root -"
      "d /var/lib/rancher/k3s/server 0755 root root -"
      "d /etc/rancher 0755 root root -"
      "d /etc/rancher/k3s 0755 root root -"
    ];
  };
}