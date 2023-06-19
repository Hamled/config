{
  description = "NixOS configurations";

  inputs = {
    flake-compat.url = "github:nix-community/flake-compat";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = inputs:
    let users = import ./users inputs;
    in {
      nixosConfigurations = {
        hana = import ./machines/hana inputs { inherit (users) charles; };
      };
    };
}
