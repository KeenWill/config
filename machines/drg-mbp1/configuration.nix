{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager

    ./hardware-configuration.nix

    ./../../modules/darwin/base.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      williamgoeller = {
        imports = [
          ./../../modules/home-manager/base.nix
          # ./../../modules/home-manager/fonts.nix
          # ./../../modules/home-manager/alacritty.nix
          ./../../modules/home-manager/1password.nix
        ];
      };
    };
  };

  networking = {
    hostName = "drg-mbp1";
    computerName = "drg-mbp1";
    localHostName = "drg-mbp1";
  };
}
