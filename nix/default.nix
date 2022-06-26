{ inputs, config, lib, pkgs, ... }:

with lib;
with lib.my;
{
  imports = (mapModulesRec' (toString ./modules) import);
}
