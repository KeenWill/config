{ modules, pkgs, lib, ... }:
with lib;
let
  inherit (builtins) readDir;

  mapFilterAttrs = pred: f: attrs: filterAttrs pred (mapAttrs' f attrs);

  mapModules = dir: fn:
    mapFilterAttrs
      (n: v:
        v != null &&
        !(hasPrefix "_" n))
      (n: v:
        let path = "${toString dir}/${n}"; in
        if v == "directory" && pathExists "${path}/default.nix"
        then nameValuePair n (fn path)
        else if v == "regular" &&
          n != "default.nix" &&
          hasSuffix ".nix" n
        then nameValuePair (removeSuffix ".nix" n) (fn path)
        else nameValuePair "" null)
      (readDir dir);

  mapModules' = dir: fn:
    attrValues (mapModules dir fn);
in
{
  imports = [ ../modules ];
}