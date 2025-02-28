{
  pkgs,
  osConfig,
  ...
}:
{
  home = {
    packages =
      with pkgs;
      [
        bat
        bind
        btop
        cbonsai
        clolcat
        cmatrix
        croc
        dua
        du-dust
        duf
        figlet
        fortune-kind
        gallery-dl
        gdu
        genact
        gti
        htop
        hyperfine
        imagemagick
        jdupes
        kopia
        neo-cowsay
        neofetch
        neovim
        nixfmt-rfc-style
        pandoc
        pipes-rs
        poppler_utils
        qrencode
        rg
        smartmontools
        tree
        vim
        yt-dlp
      ]
      # Below packages are for development and therefore excluded from servers
      # inspo: https://discourse.nixos.org/t/how-to-use-hostname-in-a-path/42612/3
      ++ (
        if builtins.substring 0 3 osConfig.networking.hostName != "svr" then
          [
        #     alejandra
            # inspo: https://mynixos.com/nixpkgs/package/azure-cli
        #     (azure-cli.withExtensions [ azure-cli.extensions.k8s-extension ])
            bun
            devenv
            doppler
            flyctl
            just
            kubectl
            kubernetes-helm
            nil
            nixos-rebuild # need for macOS
            nodejs
            sops
            statix
            zola
	    ssh-to-age
          ]
        else
          [ ]
      );
  };
}
