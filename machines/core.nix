{ lib, pkgs, inputs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      git
      gptfdisk
      lsof
      vim
      wget
      htop

      man
      man-pages
      man-pages-posix
    ];
  };

  users.mutableUsers = true;

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (final: prev: {
        unstable = import inputs.latest {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      })
    ];
  };

  nix = (let
    substituters = {
      "https://nix-community.cachix.org" =
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    };
  in {
    systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    useSandbox = true;

    gc.automatic = true;
    autoOptimiseStore = true;
    optimise.automatic = true;

    trustedUsers = [ "root" "@wheel" ];
    allowedUsers = [ "@wheel" ];

    extraOptions = ''
      min-free = ${toString (512 * 1024 * 1024)}
      keep-outputs = true
      keep-derivations = true
      fallback = true

      extra-experimental-features = nix-command flakes
      extra-substituters = ${
        lib.concatStringsSep " " (builtins.attrNames substituters)
      }
      extra-trusted-public-keys = ${
        lib.concatStringsSep " " (builtins.attrValues substituters)
      }
    '';

    nixPath = [
      "nixpkgs=${inputs.nixos}"
      "nixpkgs-latest=${inputs.latest}"
      "nixos-config=${inputs.self}"
      "home-manager=${inputs.home}"
    ];
  });

  hardware.enableRedistributableFirmware = true;
}
