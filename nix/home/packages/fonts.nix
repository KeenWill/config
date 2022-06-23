{ config, pkgs, lib, ... }:

with lib;

{
  config = {
    home.packages = with pkgs; [
      dejavu_fonts
      fira-code
      fira-code-symbols
      font-awesome
      freefont_ttf
      go-font
      gyre-fonts
      liberation_ttf
      mplus-outline-fonts
      nerdfonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      proggyfonts
      unifont
      xkcd-font
    ];
  };
}
