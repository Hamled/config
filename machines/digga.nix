{ lib, pkgs, inputs, ... }:
let
  # Used to recreate FUP's generateRegistryFromInputs option
  flakes = lib.filterAttrs (name: value:
    !(builtins.elem name [ "self" "old-config" ]) && value ? outputs) inputs;
  nixRegistry = builtins.mapAttrs (name: v: { flake = v; }) flakes;
in {
  nix = {
    # This option comes from FUP so we recreate the effect here
    #generateRegistryFromInputs = lib.mkDefault true;
    registry = nixRegistry // { self.flake = inputs.old-config; };

    package = pkgs.nixVersions.nix_2_9;
  };

  # Hack to match old config
  system.configurationRevision = "58953c21e6f3ef2fbf7680d18567e9d7c9bf76eb";
}
