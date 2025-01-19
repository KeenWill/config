# flake.nix

{
  description = "Darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    cachix-deploy-flake.url = "github:cachix/cachix-deploy-flake";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      deploy-rs,
      flake-utils, 
      cachix-deploy-flake,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    flake-utils.lib.eachDefaultSystem (
      system: {
        defaultPackage = let
              pkgs = import nixpkgs { inherit system; };
              cachix-deploy-lib = cachix-deploy-flake.lib pkgs;
            in
              cachix-deploy-lib.spec {
                agents = {
                  gh-actions = cachix-deploy-lib.nixos self.nixosConfigurations.wkg-server0.config.system.build.toplevel;
                };
              };
      };
    ) // 
    {
      
   
      darwinConfigurations = {
        "drg-mbp1" = nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./machines/drg-mbp1/configuration.nix ];
        };
      };
      nixosConfigurations = {
        "wkg-server0" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./machines/wkg-server0/configuration.nix ];
        };
        # "iso-aarch64-linux" = nixpkgs.lib.nixosSystem {
        #   system = "aarch64-linux";
        #   specialArgs = {
        #     inherit inputs outputs;
        #   };
        #   modules = [
        #     (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
        #     ./machines/iso-aarch64-linux/configuration.nix
        #   ];
        # };
      };

        deploy.nodes."wkg-server0" = {
          # sshOpts = [ "-p" "22" ];
          hostname = "wkg-server0";
          # fastConnection = true;
          interactiveSudo = false;
          remoteBuild = true;
          profiles = {
            system = {
              sshUser = "wkg";
              path =
                deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."wkg-server0";
              user = "root";
            };
            # hello = {
            #   sshUser = "hello";
            #   path = deploy-rs.lib.x86_64-linux.activate.custom self.defaultPackage.x86_64-linux "./bin/activate";
            #   user = "hello";
            # };
          };
      };
      # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
