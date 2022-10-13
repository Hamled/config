{ suites, pkgs, ... }: {
  imports = suites.base;
  home.packages = with pkgs; [ hello htop nix-index ];

  programs.bash = {
    enable = true;
    initExtra = ''
      set -o vi
    '';
  };
}
