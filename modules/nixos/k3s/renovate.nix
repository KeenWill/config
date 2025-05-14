# Renovate automation for dependency updates
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.renovate;
in
{
  options.services.renovate = {
    enable = mkEnableOption "Renovate dependency update tool";

    gitRepository = mkOption {
      type = types.str;
      default = "";
      example = "https://github.com/username/repo.git";
      description = "URL of the Git repository to update";
    };

    configFile = mkOption {
      type = types.str;
      default = "/etc/renovate/renovate-config.json";
      description = "Path to Renovate configuration file";
    };

    schedule = mkOption {
      type = types.str;
      default = "0 0 * * *"; # Daily at midnight
      description = "Cron schedule for running Renovate";
    };

    tokenFile = mkOption {
      type = types.str;
      default = "/var/lib/renovate/token";
      description = "Path to file containing GitHub/GitLab token";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nodejs
      git
    ];

    # Install Renovate globally with npm
    system.activationScripts.installRenovate = ''
      if ! command -v renovate &> /dev/null; then
        ${pkgs.nodejs}/bin/npm install -g renovate
      fi
    '';

    # Create basic renovate config if it doesn't exist
    system.activationScripts.createRenovateConfig = ''
            mkdir -p "$(dirname ${cfg.configFile})"
            if [ ! -f "${cfg.configFile}" ]; then
              cat > "${cfg.configFile}" << EOF
      {
        "$schema": "https://docs.renovatebot.com/renovate-schema.json",
        "extends": [
          "config:base"
        ],
        "kubernetes": {
          "fileMatch": ["\\.yaml$", "\\.yml$"]
        },
        "helm-values": {
          "fileMatch": ["values\\.yaml$"]
        },
        "flux": {
          "fileMatch": ["flux/.*\\.yaml$"]
        },
        "packageRules": [
          {
            "matchUpdateTypes": ["minor", "patch"],
            "matchCurrentVersion": "!/^0/",
            "automerge": true
          }
        ]
      }
      EOF
            fi
    '';

    # Create systemd timer for renovate
    systemd.timers.renovate = {
      wantedBy = [ "timers.target" ];
      partOf = [ "renovate.service" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
      };
    };

    # Create systemd service for renovate
    systemd.services.renovate = {
      description = "Renovate Dependency Update Service";
      after = [ "network.target" ];
      environment = {
        NODE_PATH = "${pkgs.nodejs}/lib/node_modules";
        RENOVATE_CONFIG_FILE = cfg.configFile;
        GITHUB_COM_TOKEN = "$(cat ${cfg.tokenFile})";
      };

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.nodejs}/bin/renovate ${cfg.gitRepository}";
        User = "renovate";
        Group = "renovate";
      };
    };

    # Create user and group for renovate
    users.users.renovate = {
      isSystemUser = true;
      group = "renovate";
      home = "/var/lib/renovate";
      createHome = true;
      description = "Renovate service user";
    };

    users.groups.renovate = { };

    # Create needed directories
    systemd.tmpfiles.rules = [
      "d /var/lib/renovate 0750 renovate renovate -"
    ];
  };
}
