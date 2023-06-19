inputs@{ nixpkgs, ... }:
users:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [ ../core.nix ./configuration.nix ];
}
