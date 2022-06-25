{ inputs, lib, pkgs, ... }:

with lib;
with lib.my;
with inputs.darwin.lib;
let
  sys = "x86_64-linux";
  hostType = "nixos";
  homeManagerStateVersion = "22.05";
  name = mkDefault (removeSuffix ".nix" (baseNameOf path));
in
{
  mkHost = path: attrs @ { system ? sys, hostType ? hostType, ... }:
    if hostType == "nixos" then
      (nixosSystem
        {
          inherit system;
          specialArgs = { inherit lib inputs system; };
          modules = [
            {
              nixpkgs.pkgs = pkgs;
              networking.hostName = name;
            }
            (filterAttrs (n: v: !elem n [ "system" ]) attrs)
            # ../. # /default.nix
            (import path)
          ];
        })
    else if hostType == "darwin" then
      {
        name = darwinSystem {
          inherit system;
          specialArgs = { inherit lib inputs system; };
          modules = [
            {
              nixpkgs.pkgs = pkgs;
              networking.computerName = name;
              networking.hostName = name;
              networking.knownNetworkServices = [
                "Wi-Fi"
                "USB 10/100/1000 LAN"
              ];
            }
            (filterAttrs (n: v: !elem n [ "system" ]) attrs)
            # ../. # /default.nix
            (import path)
          ];
        };
      }
    else
      (home-manager.lib.homeManagerConfiguration
        {
          inherit system;
          stateVersion = homeManagerStateVersion;
          specialArgs = { inherit lib inputs system; };
          # homeDirectory = "/home/williamgoeller";
          # username = "williamgoeller";
          configuration = {
            imports = [ homeManagerDarwinConfig ]; # TODO: should rename this to be linux. but not nixos
            nixpkgs = nixpkgsConfig;
          };
        });

  mapHosts = dir: attrs @ { system ? system, hostType ? hostType, ... }:
    mapModules dir
      (hostPath: mkHost hostPath attrs);
}
