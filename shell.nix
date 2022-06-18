{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = with pkgs;
    [
      age
      agebox
      ansible
      clang
      direnv
      fluxcd
      gitleaks
      go
      go-task
      ipcalc
      jq
      kubectl
      kubernetes-helm
      kustomize
      libiconv
      nixpkgs-fmt
      nodePackages.prettier
      pre-commit
      shellcheck
      sops
      stern
      terraform
      yamllint
      yq
    ];
}
