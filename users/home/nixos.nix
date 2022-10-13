{ suites, pkgs, ... }: {
  imports = suites.base;
  home.packages = with pkgs; [ hello htop ];
}
