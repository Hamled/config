{
  description = "NixOS configurations using Digga.";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters =
      "https://nrdxp.cachix.org https://nix-community.cachix.org";
    extra-trusted-public-keys =
      "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  };

  inputs = {
    # Track channels with commits tested and built by hydra
    nixos.url = "github:nixos/nixpkgs/nixos-22.05";
    latest.url = "github:nixos/nixpkgs/nixos-unstable";

    digga.url = "github:divnix/digga";
    digga.inputs.nixpkgs.follows = "nixos";
    digga.inputs.nixlib.follows = "nixos";
    digga.inputs.home-manager.follows = "home";

    home.url = "github:nix-community/home-manager/release-22.05";
    home.inputs.nixpkgs.follows = "nixos";

    nix-doom-emacs.url =
      "github:nix-community/nix-doom-emacs/3c02175dd06714c15ddd2f73708de9b4dacc6aa9";

    devenv.url = "github:cachix/devenv/latest";
  };

  outputs = { self, digga, nixos, home, ... }@inputs:
    let lib = import ./lib { lib = digga.lib // nixos.lib; };
    in digga.lib.mkFlake {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };

      channels = {
        nixos = {
          imports = [ (digga.lib.importOverlays ./overlays) ];
          overlays = [
            (self: super: {
              devenv = inputs.devenv.packages.x86_64-linux.devenv;
            })
          ];
        };
        latest = { };
      };

      sharedOverlays = (lib.sharedOverlays self) ++ [ ];

      nixos = {
        hostDefaults = {
          system = "x86_64-linux";
          channelName = "nixos";
          imports = [ (digga.lib.importExportableModules ./modules/nixos) ];
          modules = [
            { lib.our = self.lib; }
            digga.nixosModules.bootstrapIso
            digga.nixosModules.nixConfig
            home.nixosModules.home-manager
          ];
        };

        hosts = { };

        imports = [ (digga.lib.importHosts ./hosts) ];
        importables = rec {
          profiles = digga.lib.rakeLeaves ./profiles/nixos // {
            users = digga.lib.rakeLeaves ./users/nixos;
          };

          suites = with profiles; rec { base = [ core ]; };
        };
      };

      home = {
        users = digga.lib.rakeLeaves ./users/home;

        imports = [ (digga.lib.importExportableModules ./modules/home) ];
        modules = [ inputs.nix-doom-emacs.hmModule ];
        importables = rec {
          profiles = digga.lib.rakeLeaves ./profiles/home;
          suites = with profiles; rec { base = [ core ]; };
        };
      };

      devshell = ./shell;
    };
}
