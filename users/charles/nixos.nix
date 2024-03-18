{ config, lib, pkgs, inputs, ... }: {
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
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrtf2GddsSshWOjrpKK1uAq5MG9bsywctp8bTfwHSCl charles@hana"
    ];
  };

  environment.variables = { EDITOR = "vim"; };

  programs.ssh.startAgent = true;

  security.pam.services.swaylock = { };

  nixpkgs.overlays = [
    (final: prev: { devenv = inputs.devenv.packages.x86_64-linux.devenv; })
  ];
}
