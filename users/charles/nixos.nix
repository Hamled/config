{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  users.users.charles = {
    description = "Charles Ellis";
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "docker"
      "wireshark"
      "libvirtd"
      "openvpn"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrtf2GddsSshWOjrpKK1uAq5MG9bsywctp8bTfwHSCl charles@hana"
    ];
  };

  environment.variables = {EDITOR = "vim";};

  programs.ssh.startAgent = true;
  programs.openvpn3.enable = true;

  security.pam.services.swaylock = {};

  # Log in via greetd + tuigreet on tty1, then launch Sway. greetd runs the
  # session through `sh` and sources /etc/profile + ~/.profile, so `sway`
  # resolves to the home-manager-wrapped binary (carrying --unsupported-gpu
  # and the session env). Hit F2 in tuigreet to override the command for a
  # single login (e.g. `sway --debug`).
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
      user = "greeter";
    };
  };
}
