{
  description = "NixOS configurations";

  inputs = {
    flake-compat.url = "github:nix-community/flake-compat";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    home.url = "github:nix-community/home-manager/release-23.05";
    home.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";
  };

  outputs = inputs:
    let users = import ./users inputs;
    in {
      nixosConfigurations = {
        hana = import ./machines/hana inputs { inherit (users) charles; };
      };
    };
}
