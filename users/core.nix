{ config, lib, pkgs, ... }: {
  programs.direnv = {
    enable = true;
    nix-direnv = { enable = true; };
  };

  programs.home-manager.enable = true;

  home.stateVersion = "23.05";
}
