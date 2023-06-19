{ lib, pkgs, inputs, ... }:
let
  experimental-features = [ "flakes" "nix-command" ];
  substituters = [
    "https://nrdxp.cachix.org" # quality of life cache from our CI
    "https://nix-community.cachix.org"
  ];
  trusted-public-keys = [
    "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  # This comes from FUP's mkFlake so we recreate it here
  extraOptionsAddendum = "extra-experimental-features = nix-command flakes";

  # Used to recreate FUP's generateRegistryFromInputs option
  flakes = lib.filterAttrs (name: value:
    !(builtins.elem name [ "self" "old-config" ]) && value ? outputs) inputs;
  nixRegistry = builtins.mapAttrs (name: v: { flake = v; }) flakes;
in {
  nix = {
    # This option comes from FUP so we recreate the effect here
    #generateRegistryFromInputs = lib.mkDefault true;
    registry = nixRegistry // { self.flake = inputs.old-config; };

    # missing merge semantics in this option force us to use extra-* for now
    extraOptions = ''
      extra-experimental-features = ${
        lib.concatStringsSep " " experimental-features
      }
      extra-substituters = ${lib.concatStringsSep " " substituters}
      extra-trusted-public-keys = ${
        lib.concatStringsSep " " trusted-public-keys
      }

    '' + extraOptionsAddendum;

    binaryCaches = [
      "https://nrdxp.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    binaryCachePublicKeys = [
      "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    package = pkgs.nixVersions.nix_2_9;

    nixPath = [
      "nixpkgs=${inputs.nixos}"
      "nixpkgs-latest=${inputs.latest}"
      "nixos-config=${../lib/compat/nixos}"
      "home-manager=${inputs.home}"
    ];
  };

  # Hack to match old config
  system.configurationRevision = "58953c21e6f3ef2fbf7680d18567e9d7c9bf76eb";
}
