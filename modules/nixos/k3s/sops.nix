# SOPS secret management configuration for NixOS
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sops;
in
{
  options.sops = {
    enable = mkEnableOption "SOPS secret management";
    
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

    secrets = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          sopsFile = mkOption {
            type = types.str;
            description = "Path to the SOPS encrypted file";
          };

          format = mkOption {
            type = types.enum [ "yaml" "json" "binary" "dotenv" "ini" ];
            default = "yaml";
            description = "Format of the SOPS encrypted file";
          };

          owner = mkOption {
            type = types.str;
            default = "root";
            description = "Owner of the decrypted secret";
          };

          group = mkOption {
            type = types.str;
            default = "root";
            description = "Group of the decrypted secret";
          };

          mode = mkOption {
            type = types.str;
            default = "0400";
            description = "Permissions of the decrypted secret";
          };

          path = mkOption {
            type = types.str;
            default = "";
            description = "Path where the decrypted secret should be stored";
          };
        };
      });
      default = {};
      description = "Set of secrets to manage with SOPS";
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

    # Import sops-nix
    imports = [
      (mkIf pkgs ? sops-nix (pkgs.sops-nix.nixosModules.sops))
    ];

    # Configure sops-nix
    sops = {
      age.keyFile = cfg.age.keyFile;
      defaultSopsFile = cfg.defaultSopsFile;
    };

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