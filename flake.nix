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
    digga.inputs.deploy.follows = "deploy";

    home.url = "github:nix-community/home-manager/release-22.05";
    home.inputs.nixpkgs.follows = "nixos";

    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixos";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixos";

    nvfetcher.url = "github:berberman/nvfetcher";
    nvfetcher.inputs.nixpkgs.follows = "nixos";

    naersk.url = "github:nmattia/naersk";
    naersk.inputs.nixpkgs.follows = "nixos";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixos-generators.url = "github:nix-community/nixos-generators";
  };

  outputs = { self, digga, nixos, ... }@inputs:
    let lib = import ./lib { lib = digga.lib // nixos.lib; };
    in digga.lib.mkFlake {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };

      channels = {
        nixos = {
          imports = [ (digga.lib.importOverlays ./overlays) ];
          overlays = [ ];
        };
        latest = { };
      };

      sharedOverlays = (lib.sharedOverlays self) ++ [ ];
    };
}
