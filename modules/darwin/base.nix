{ pkgs, ... }:
{
  imports = [
    #     ./_dock.nix
    #     ./_packages.nix
    ./homebrew.nix
    ./osx-defaults.nix
  ];

  nix = {
    enable = true;
    optimise.automatic = true;
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "@admin"
      ];
    };
  };



  programs.zsh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;


  services = {
    tailscale.enable = true;
  };

  users.users.williamgoeller.home = "/Users/williamgoeller";

#   environment.shellInit = ''
#     eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
#   '';
  #   system = {
  #     startup.chime = false;
  #     defaults = {
  #       loginwindow.LoginwindowText = "If lost, contact eric@chengeric.com";
  #       screencapture.location = "~/OneDrive/30-39 Hobbies/34 Photos/34.01 Screenshots";

  #       dock = {
  #         autohide = true;
  #         mru-spaces = false;
  #         tilesize = 96;
  #         wvous-br-corner = 4;
  #         wvous-bl-corner = 11;
  #         wvous-tr-corner = 5;
  #       };

  #       finder = {
  #         AppleShowAllExtensions = true;
  #         FXPreferredViewStyle = "clmv";
  #       };

  #       menuExtraClock = {
  #         ShowSeconds = true;
  #         Show24Hour = true;
  #         ShowAMPM = false;
  #       };

  #       NSGlobalDomain = {
  #         AppleICUForce24HourTime = true;
  #         AppleInterfaceStyle = "Dark";
  #         # inspo: https://apple.stackexchange.com/questions/261163/default-value-for-nsglobaldomain-initialkeyrepeat
  #         KeyRepeat = 2;
  #         InitialKeyRepeat = 15;
  #       };
  #     };
  #   };

  #   local = {
  #     dock = {
  #       enable = true;
  #       entries = [
  #         {path = "/System/Applications/Launchpad.app";}
  #         {path = "/Applications/Firefox.app";}
  #         {path = "/Applications/Alacritty.app";}
  #         {path = "/Applications/Visual Studio Code.app";}
  #         {path = "/Applications/Discord.app";}
  #         {path = "/System/Applications/Messages.app";}
  #         {path = "/Applications/Messenger.app";}
  #         {path = "/Applications/1Password.app";}
  #         {path = "/Applications/Obsidian.app";}
  #         {path = "/System/Applications/System Settings.app";}
  #       ];
  #     };
  #   };

  #   system.activationScripts.Wallpaper.text = ''
  #     echo >&2 "Setting up wallpaper..."
  #     osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/System/Library/Desktop Pictures/Solid Colors/Black.png"'
  #   '';

  system.stateVersion = 5;
}
