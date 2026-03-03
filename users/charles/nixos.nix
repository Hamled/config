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

  nixpkgs.overlays = [
    (final: prev: {
      claude-agent-acp = prev.claude-agent-acp.overrideAttrs (finalAttrs: prevAttrs: {
        version = "0.26.0";

        src = prevAttrs.src.overrideAttrs (oldSrc: {
          owner = "agentclientprotocol";
          hash = "sha256-2G8gjMCnk3W1I2+4sNsumL15ts9bLXAOMguCmwnzWSA=";
        });

        npmDeps = prev.fetchNpmDeps {
          inherit (finalAttrs) src;
          hash = "sha256-msm4L8Yi7ma2eHOYXbZx+Qtrx4TzK7FV3HpVzRhQ19o=";
        };
      });
    })
  ];
}
