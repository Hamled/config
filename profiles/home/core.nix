{
  programs.direnv = {
    enable = true;
    nix-direnv = { enable = true; };
  };

  programs.home-manager.enable = true;
}
