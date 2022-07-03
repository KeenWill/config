{ modules, pkgs, ... }:
{
  imports = [ ../import.nix ];

  ## Modules
  config.modules = {
    darwin.homebrew.enable = true;
  };
}
