# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "wkg-server0"; 

  time.timeZone = "America/New_York";

  users.users.wkg = {
    isNormalUser = true;
    description = "William Goeller";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICXw4ngDYWRRiyF8TqrJ3yXQ7xHTRQr6QbZjY3uM1hGr william@williamgoeller.com"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim 
    wget
    htop
  ];

  services.openssh.enable = true;
  services.cachix-agent.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 8123 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "America/New_York";
      image = "ghcr.io/home-assistant/home-assistant:2025.1";
      extraOptions = [ 
        "--network=host" 
        # "--device=/dev/ttyACM0:/dev/ttyACM0"  # Example, change this to match your own hardware
      ];
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}