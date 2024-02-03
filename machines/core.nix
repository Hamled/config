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
        unstable = import inputs.nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      })
      (final: prev: {
        nixos-23_11 = import inputs.nixos-23_11 {
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
      "https://devenv.cachix.org" =
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
      "https://nixpkgs-python.cachix.org" =
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=";
      "https://nixpkgs-terraform.cachix.org" =
        "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw=";
    };
  in {
    settings = {
      system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      sandbox = true;
      auto-optimise-store = true;

      trusted-users = [ "root" "@wheel" ];
      allowed-users = [ "@wheel" ];
    };

    gc.automatic = true;
    optimise.automatic = true;

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
      "nixpkgs=${pkgs.path}"
      "nixpkgs-latest=${pkgs.unstable.path}"
      "nixos-config=${inputs.self}"
      "home-manager=${inputs.home}"
    ];

    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nixpkgs-latest.flake = inputs.nixpkgs-unstable;
      home-manager.flake = inputs.home;
    };
  });

  hardware.enableRedistributableFirmware = true;

  system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
}
