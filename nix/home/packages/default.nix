{ config, ... }: {
  imports = [
    ./cloud.nix
    ./containers.nix
    ./fonts.nix
    ./go.nix
    ./haskell.nix
    ./k8s.nix
    ./nix.nix
    ./node.nix
    ./python.nix
    ./ruby.nix
    ./tools.nix
    ./virt.nix
  ];
}
