# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./htpc/htcp.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "tank" "primary" ];

  networking.hostName = "wkg-server0"; 
  networking.hostId = "52ff0c0a";

  time.timeZone = "America/New_York";

  users.users.wkg = {
    isNormalUser = true;
    description = "William Goeller";
    extraGroups = [ "networkmanager" "wheel" "podman" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICXw4ngDYWRRiyF8TqrJ3yXQ7xHTRQr6QbZjY3uM1hGr william@williamgoeller.com"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
cowsay # A novelty program that generates ASCII art of a cow (or other characters) saying a message.
bat # A “cat” clone with syntax highlighting and Git integration for enhanced file viewing.
bind # DNS software for translating domain names to IP addresses (Berkeley Internet Name Domain).
btop # An interactive resource monitor displaying real‑time CPU, memory, network, and disk usage.
croc # A simple tool for securely transferring files and folders between computers across networks.
dmidecode # A tool for dumping system hardware information from the BIOS, useful for diagnostics.
docker-compose # A tool for defining and running multi‑container Docker applications using YAML configuration files.
du-dust # A modern, human‑friendly alternative to the traditional du command, summarizing disk usage clearly.
dua # A disk usage analyzer designed to quickly show how storage is being used.
duf # A utility that presents disk usage and filesystem statistics in an easy‑to‑read table.
fio # A flexible I/O tester that simulates various I/O workloads to benchmark and stress test storage devices.
hdparm # A command‑line utility for configuring, optimizing, and testing hard disk drive parameters including performance tuning and power management.
figlet # A program that creates large text banners from plain text using ASCII art fonts.
gallery-dl # A command‑line downloader for extracting images and media from online galleries and hosting sites.
gdu # A fast disk usage analyzer that quickly scans directories and reports space usage.
genact # A tool for generating activity reports or logs to summarize project or system activity.
gti # An enhanced Git interface that provides shortcuts and additional functionality for Git tasks.
htop # An interactive process viewer and system monitor with a colorful, user‑friendly display.
hyperfine # A command‑line benchmarking tool to measure and compare the execution times of commands.
imagemagick # A comprehensive suite of tools and libraries for converting, editing, and composing bitmap images.
ipmitool # A utility for interfacing with devices that support IPMI, commonly used for server management.
jdupes # A utility for finding and eliminating duplicate files on a system.
kopia # A fast, secure, and open‑source backup tool for efficiently backing up files and directories.
neo-cowsay # A variant of cowsay that may include additional characters or styles for generating ASCII art messages.
neofetch # A command‑line system information tool that displays detailed hardware and OS information.
neovim # A modern, extensible refactoring of the classic Vim text editor aimed at improved usability and performance.
nixfmt-rfc-style # A formatter for Nix language code that enforces a specific style guideline for consistent coding.
pandoc # A universal document converter that transforms files between a wide variety of markup formats.
pciutils # A collection of tools for interacting with PCI devices (provides lspci for detailed PCI information).
pipes-rs # A fun terminal tool that animates “pipes” (ASCII art lines) across your terminal for aesthetic flair.
podman-compose # A docker-compose–like tool tailored for managing containers with Podman.
poppler_utils # A set of utilities based on the Poppler library for converting and extracting data from PDFs.
qrencode # A tool that converts text input into a QR Code image.
ripgrep # A fast, recursive search tool with regex support, similar to grep but optimized for speed.
smartmontools # Utilities that monitor and analyze storage device health using S.M.A.R.T. data.
sysstat # A suite of performance monitoring tools that collect and report system activity and resource usage.
tree # A utility that visually displays directory structures in a tree-like format.
vim # A highly configurable text editor based on vi, popular among developers for efficient editing.
wget # A non‑interactive network downloader capable of retrieving files via HTTP, HTTPS, and FTP protocols.
yt-dlp # An enhanced fork of youtube-dl that downloads videos and audio from YouTube and other sites.
tmux 
uidmap
  ];
  services.openssh.enable = true;
  services.cachix-agent.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 443 8123 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  # allow tailscale through the firewall
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];


  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        "use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "10.0.1. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        "getwd cache" = "true";

        # Disable [strict sync] and [sync always] to allow ZFS to handle caching
        "strict sync" = "no";
        "sync always" = "no";

        # Enable asynchronous I/O for better performance
        "aio read size" = "16384";
        "aio write size" = "16384";

        "min receivefile size" = "16384";
      };
      "tank" = {
        "path" = "/tank";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "wkg";
        "writeable" = "yes";
      };
      "primary" = {
        "path" = "/primary";
        "guest ok" = "no";
        "create mask" = "644";
        "directory mask" = "755";
        "force user" = "wkg";
        "writeable" = "yes";
      };
      "tm_share" = {
          "path" = "/tank/timemachine";
          "valid users" = "wkg";
          "public" = "no";
          "writeable" = "yes";
          "force user" = "wkg";
          "fruit:aapl" = "yes";
          "fruit:time machine" = "yes";
          "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };


  services.tailscale.enable = true;



 # networking.bridges.br0.interfaces = [ "eno4" ];

  # systemd.services.create-podman-network = with config.virtualisation.oci-containers; {
	# serviceConfig.Type = "oneshot";
	# wantedBy = [ "podman-homer.service" ];
	# script = ''${pkgs.podman}/bin/podman network exists net_macvlan || \ ${pkgs.podman}/bin/podman network create --driver=macvlan --gateway=192.168.xx.1 --subnet=192.168.xx.0/24 -o parent=eno4 net_macvlan'';
  # };

  # virtualisation.oci-containers = {
  #   backend = "podman";
  #   containers = {
	# home-assistant = import ./containers/home-assistant.nix;
	# homer = import ./containers/homer.nix;
      
  #   };
  # };

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
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
