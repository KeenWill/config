{
  description = "wgoeller-cfg";

  inputs = {

    # Package sets
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-22.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-22.05";

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # nixpkgs.url = "nixpkgs/master"; # primary nixpkgs
    #   nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable"; # for packages on the edge
    #   darwin.url = github:LnL7/nix-darwin; # at least it's not windows!
    #   darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    #   home-manager.url = github:nix-community/home-manager/master;
    #   home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "nixpkgs";
      prefmanager.url = github:malob/prefmanager;
      prefmanager.inputs.nixpkgs.follows = "nixpkgs-unstable";

      # Extras
      emacs-overlay.url = "github:nix-community/emacs-overlay";
      nixos-hardware.url = "github:nixos/nixos-hardware";
  };
  outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
#   outputs = inputs:
    let

      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverridable optionalAttrs singleton;

      # Configuration for `nixpkgs`
        nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays ++ singleton (
            # Sub in x86 version of packages that don't build on Apple Silicon yet
            final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            inherit (final.pkgs-x86)
                idris2
                nix-index
                niv
                purescript;
            })
        );
        }; 
    #   # TODO: further cleanup via usage of "nixlib"
    #   nixlib = inputs.nixlib.outputs.lib;
    #   supportedSystems = [
    #     "x86_64-linux"
    #     "aarch64-linux"
    #     "riscv64-linux"
    #     "aarch64-darwin"
    #     "x86_64-darwin"
    #     # "riscv64-none-elf" # TODO
    #     # "armv6l-linux" # eh, I think time is up
    #     # "armv7l-linux" # eh, I think time is up
    #   ];
    #   forAllSystems = nixlib.genAttrs supportedSystems;
    #   filterPkg_ = system: (n: p: (builtins.elem "${system}" (p.meta.platforms or [ "x86_64-linux" "aarch64-linux" ])) && !(p.meta.broken or false));
    #   filterPkgs = pkgs: pkgSet: (pkgs.lib.filterAttrs (filterPkg_ pkgs.system) pkgSet);
    #   filterHosts = pkgs: cfgs: (pkgs.lib.filterAttrs (n: v: pkgs.system == v.config.nixpkgs.system) cfgs);

      _lib = rec {
        # force_cached = sys: pkgs_.nixpkgs."${sys}".callPackage ./lib/force_cached.nix { };
        # minimalMkShell = system: import ./lib/minimalMkShell.nix { pkgs = fullPkgs_.${system}; };
        # hydralib = import ./lib/hydralib.nix;
        # pkgsFor = pkgs: system: overlays:
        #   import pkgs {
        #     inherit system overlays;
        #     config.allowUnfree = true;
        #   };
        # pkgs_ = nixlib.genAttrs (builtins.attrNames inputs) (inp: nixlib.genAttrs supportedSystems (sys: pkgsFor inputs."${inp}" sys [ ]));
        # fullPkgs_ = nixlib.genAttrs supportedSystems (sys:
        #   pkgsFor inputs.nixpkgs sys [ inputs.self.overlay inputs.nixpkgs-wayland.overlay ]);
        mkDarwinSystem_ = pkgs: system: h: modules:
          darwin.lib.darwinSystem {
            system = system;
            modules = [ 
                ./hosts/${h}/configuration.nix
                home-manager.darwinModules.home-manager
                
            ] ++ modules;
            specialArgs = { inherit inputs; };
          };
        mkNixOSSystem_ = pkgs: system: h: modules:
          pkgs.lib.nixosSystem {
            system = system;
            modules = [ ./hosts/${h}/configuration.nix ] ++ modules;
            specialArgs = { inherit inputs; };
          };
        mkDarwinSystem = pkgs: system: h: (mkDarwinSystem_ pkgs system h [ ./hosts/${h}/configuration.nix ]);
        mkNixOSSystem = pkgs: system: h: (mkNixOSSystem_ pkgs system h [ ./hosts/${h}/configuration.nix ]);

        # pkgNames = s: builtins.attrNames (inputs.self.overlay pkgs_.${s} pkgs_.${s});
      };

    #   _inputs = inputs;

    in
    with _lib; rec {
      
      darwinConfigurations = {
        zeus = mkDarwinSystem inputs.nixpkgs "aarch64-darwin" "zeus";
      };

    };
}



