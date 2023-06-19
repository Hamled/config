inputs@{ nixpkgs, ... }:
users:
let usersMods = builtins.map (config: config.nixos) (builtins.attrValues users);
in nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [ ../core.nix ./configuration.nix ] ++ usersMods;
}
