# SOPS secret management configuration for NixOS
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.k3s.sops;
in
{
  options.k3s.sops = {
    enable = mkEnableOption "SOPS secret management for k3s";
    
    age = {
      keyFile = mkOption {
        type = types.str;
        default = "/var/lib/sops-nix/key.txt";
        description = "Path to age key file";
      };

      generateKey = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to generate an age key if it doesn't exist";
      };
    };

    defaultSopsFile = mkOption {
      type = types.str;
      default = "";
      description = "Default SOPS file to use for secrets";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
      age
    ];

    # Create a service to generate age key if requested
    systemd.services.sops-generate-age-key = mkIf cfg.age.generateKey {
      description = "Generate age key for SOPS";
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      
      script = ''
        if [ ! -f ${cfg.age.keyFile} ]; then
          mkdir -p "$(dirname ${cfg.age.keyFile})"
          ${pkgs.age}/bin/age-keygen -o ${cfg.age.keyFile}
          chmod 600 ${cfg.age.keyFile}
        fi
      '';
    };
  };
}