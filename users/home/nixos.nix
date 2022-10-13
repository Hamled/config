{ suites, pkgs, ... }: {
  imports = suites.base;
  home.packages = with pkgs; [ htop nix-index ];

  programs.bash = {
    enable = true;
    initExtra = ''
      set -o vi
    '';
  };
}
