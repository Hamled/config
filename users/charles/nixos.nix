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
}
