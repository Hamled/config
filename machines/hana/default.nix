inputs@{ nixpkgs, ... }:
users:
let
  usersMods = builtins.map (config: config.nixos) (builtins.attrValues users);
  usersHome = builtins.mapAttrs (user: config: config.home) users;
in nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs usersHome; };
  modules = [ ./configuration.nix ../core.nix ../core-home.nix ] ++ usersMods;
}
