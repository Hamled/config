{
  description = "NixOS configurations";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05"; };

  outputs = inputs: { nixosConfigurations = { }; };
}
