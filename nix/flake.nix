# flake.nix

{
  description = "An overly bloated nix mess.";

  inputs =
    {
      # Core dependencies.
      nixpkgs.url = "nixpkgs/nixos-unstable"; # primary nixpkgs
      nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable"; # for packages on the edge
      darwin.url = github:LnL7/nix-darwin; # at least it's not windows!
      darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
      home-manager.url = github:nix-community/home-manager/master;
      home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "nixpkgs";
      prefmanager.url = github:malob/prefmanager;
      prefmanager.inputs.nixpkgs.follows = "nixpkgs-unstable";

      # Extras
      emacs-overlay.url = "github:nix-community/emacs-overlay";
      nixos-hardware.url = "github:nixos/nixos-hardware";
    };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, darwin, ... }:
    let
      inherit (darwin.lib) darwinSystem;
      inherit (lib.my) mapModules mapModulesRec mapHosts;

      system = "x86_64-linux"; # will be overriden for apple silicon

      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true; # forgive me Stallman senpai
        overlays = extraOverlays ++ (lib.attrValues self.overlays);
      };
      pkgs = mkPkgs nixpkgs [ self.overlay ];
      pkgs' = mkPkgs nixpkgs-unstable [ ];

      lib = nixpkgs.lib.extend
        (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });
    in
    {
      lib = lib.my;

      overlay =
        final: prev: {
          unstable = pkgs';
          my = self.packages."${system}";
        };

      #   overlays =
      #     mapModules ./overlays import;

      #   packages."${system}" =
      #     mapModules ./packages (p: pkgs.callPackage p {});

      nixosModules =
        { dotfiles = import ./.; } // mapModulesRec ./modules import;

      nixosConfigurations =
        mapHosts ./hosts/nixos { hostType = "nixos"; };

      darwinConfigurations =
        mapHosts ./hosts/darwin { hostType = "darwin"; };

      homeManagerConfigurations =
        mapHosts ./hosts/general { hostType = "other"; };

      devShell."${system}" =
        import ./shell.nix { inherit pkgs; };

      templates = {
        full = {
          path = ./.;
          description = "A grossly incandescent nixos config";
        };
      } // import ./templates;
      defaultTemplate = self.templates.full;

      defaultApp."${system}" = {
        type = "app";
        program = ./bin/hey;
      };
    };
}
