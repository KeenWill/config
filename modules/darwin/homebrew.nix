# darwin.nix

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf elem;
in
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.neofetch
    pkgs.vim
    pkgs.neovim
    pkgs.nixfmt-rfc-style
    pkgs.rclone
  ];

  # nixpkgs.config.allowUnsupportedSystem = true;

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  nix.enable = true;
  #services.karabiner-elements.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  #system.configurationRevision = self.rev or self.dirtyRev or null;

  security.pam.services.sudo_local.touchIdAuth = true;

  environment.shellInit = ''
    eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
  '';

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    global.brewfile = true;
    onActivation.extraFlags = [ "--force" ];

    taps = [ "vladdoster/formulae" ];
    brews = [
      "cowsay"
      "mas"
      "opam"
      "ipmitool"
      "rclone"
    ];
    casks = [
      "1password"
      "adobe-creative-cloud"
      "anaconda"
      "autodesk-fusion"
      "backblaze"
      "balenaetcher"
      "bambu-studio"
      "bettertouchtool"
      "carbon-copy-cloner"
      "chatgpt"
      "cursor"
      "darktable"
      "digikam"
      "discord"
      "docker"
      "emacs"
      "eul"
      "firefox"
      "google-chrome"
      "google-drive"
      "gpg-suite"
      "intellij-idea"
      "iterm2"
      "kap"
      "kicad"
      "mactex"
      "microsoft-office"
      "minecraft"
      "miniforge"
      "notion"
      "obsidian"
      "openscad"
      "parallels"
      "prusaslicer"
      "qflipper"
      "raspberry-pi-imager"
      "slack"
      "spotify"
      "steam"
      "teamviewer"
      "vimari"
      "visual-studio-code"
      "vmware-fusion"
      "xquartz"
      "yubico-yubikey-manager"
      "zoom"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      Keynote = 409183694;
      Numbers = 409203825;
      Pages = 409201541;
      "Things 3" = 904280696;
      Xcode = 497799835;
      Messenger = 1480068668;
      #  Bear = 1091189122;
      #  "2048 Game" = 871033113;
      ColorSlurp = 1287239339;
      #  Jira = 1475897096;
      Taurine = 960276676;
      # Infuse = 1136220934;
      #   Honey = 1472777122;
      Compressor = 424390742;
      "Final Cut Pro" = 424389933;
      "Logic Pro" = 634148309;
      "Tailscale" = 1475387142;
      "Microsoft Remote Desktop" = 1295203466;
      #  "Apple Configurator 2" = 1037126344;
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.williamgoeller = {
    name = "williamgoeller";
    home = "/Users/williamgoeller";
  };
}
