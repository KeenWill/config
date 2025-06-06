{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./packages.nix
    #     ./_zsh.nix
  ];

  home = {
    username = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isLinux "wkg")
      (lib.mkIf pkgs.stdenv.isDarwin "williamgoeller")
    ];
    homeDirectory = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isLinux "/home/wkg")
      (lib.mkIf pkgs.stdenv.isDarwin "/Users/williamgoeller")
    ];
    stateVersion = "25.05";
    #     sessionVariables = lib.mkIf pkgs.stdenv.isDarwin {
    #       SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    #     };
  };

  programs = {
    ssh = {
      enable = true;
      matchBlocks = {
        wkg-server0 = {
          port = 22;
          hostname =  "wkg-server0";
          user = "wkg";
        };
      };
    };
    git = {
      enable = true;
      extraConfig = {
        user.name = "William Goeller";
        user.email = "william@williamgoeller.com";
        pull.rebase = "true";
        core.editor = "nvim";

      };
      # delta = {
      #   enable = true;
      # };
    };
    #     helix = {
    #       enable = true;
    #       defaultEditor = true;
    #       settings = {
    #         theme = "dark_high_contrast";
    #       };
    #     };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    #     zellij = {
    #       enable = true;
    #       settings = {
    #         theme = "dracula";
    #       };
    #     };
    #     tealdeer = {
    #       enable = true;
    #       settings.updates.auto_update = true;
    #     };
    #     lsd = {
    #       enable = true;
    #       enableAliases = true;
    #     };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    
    #     ranger.enable = true;
    #     fastfetch.enable = true;
  };

  # Nicely reload system units when changing configs
  # Self-note: nix-darwin seems to luckily ignore this setting
  #   systemd.user.startServices = "sd-switch";
}
