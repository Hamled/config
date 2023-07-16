{
  description = "NixOS configurations";

  inputs = {
    flake-compat.url = "github:nix-community/flake-compat";

    nixos.url = "github:NixOS/nixpkgs/nixos-22.05";
    latest.url = "github:NixOS/nixpkgs/nixos-unstable";

    home = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixos";
    };

    devenv.url =
      "github:cachix/devenv/6455f319fc90e0be2071327093c5458f9afc61bf";

    nix-doom-emacs.url =
      "github:nix-community/nix-doom-emacs/3c02175dd06714c15ddd2f73708de9b4dacc6aa9";
  };

  outputs = inputs:
    let users = import ./users inputs;
    in {
      nixosConfigurations = {
        hana = import ./machines/hana inputs { inherit (users) charles; };
      };
    };
}
