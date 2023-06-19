{ config, lib, pkgs, ... }: {
  # Nix configuration
  system.stateVersion = "22.05";

  # System configuration
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
}
