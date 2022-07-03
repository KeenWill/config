{ config, lib, pkgs, ... }:
with lib;
let
    mkIfCaskPresent = cask: lib.mkIf (lib.any (x: x == cask) config.homebrew.casks);
    brewBinPrefix = if pkgs.system == "aarch64-darwin" then "/opt/homebrew/bin" else "/usr/local/bin";

    cfg = config.modules.darwin.homebrew;
    mkBoolOpt = default: mkOption {
        inherit default;
        type = types.bool;
        example = true;
    };
in

{
    options.modules.darwin.homebrew = {
    enable = mkBoolOpt false;
  };
    config = mkMerge [
    (mkIf cfg.enable {
        environment.shellInit = ''
            eval "$(${brewBinPrefix}/brew shellenv)"
        '';

        homebrew.enable = true;
        homebrew.brewPrefix = brewBinPrefix;
        homebrew.autoUpdate = true;
        homebrew.cleanup = "zap";
        homebrew.global.brewfile = true;
        homebrew.global.noLock = true;

        homebrew.taps = [
            "homebrew/bundle"
            "homebrew/cask"
            "homebrew/cask-drivers"
            "homebrew/cask-fonts"
            "homebrew/cask-versions"
            "homebrew/core"
            "homebrew/services"
        ];

        # Prefer installing application from the Mac App Store
        #
        # Commented apps suffer continual update issue:
        # https://github.com/malob/nixpkgs/issues/9
        #
        # `mas` not working on macOS 12 beta 7
        # https://github.com/mas-cli/mas/issues/417
        homebrew.masApps = {
            "1Password" = 1333542190;
            "Apple Configurator 2" = 1037126344;
            Keynote = 409183694;
            Numbers = 409203825;
            Pages = 409201541;
            Magnet = 441258766;
            Things = 904280696;
            Xcode = 497799835;
            Messenger = 1480068668;
            Bear = 1091189122;
            "2048 Game" = 871033113;
            ColorSlurp = 1287239339;
            Jira = 1475897096;
            Taurine = 960276676;
            Infuse = 1136220934;
            Honey = 1472777122;
            Compressor = 424390742;
            "Final Cut Pro" = 424389933;
            "Logic Pro" = 634148309;
        };

        homebrew.brews = [
            "boost"
            "opam"
            "ipmitool"
            # "sshfs"
        ];

        # If an app isn't available in the Mac App Store, or the version in the App Store has
        # limitiations, e.g., Transmit, install the Homebrew Cask.
        homebrew.casks = [
            
        ];

        # Configuration related to casks
        environment.variables.SSH_AUTH_SOCK = mkIfCaskPresent "secretive"
            "/Users/${config.users.primaryUser}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";

    })
  ];
}
