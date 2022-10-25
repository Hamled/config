{ suites, pkgs, ... }: {
  imports = suites.base;

  programs = {
    bash = {
      enable = true;
      initExtra = ''
        set -o vi
      '';
    };

    ssh = {
      enable = true;

      matchBlocks = let
        defaults = {
          forwardAgent = false;
          identitiesOnly = true;
        }; in {
        GitHub = defaults // {
          host = "github.com";
          user = "git";
          identityFile = "~/.ssh/github_ed25519";
        };
      };
    };
  };

  wayland = {
    windowManager.sway = {
      enable = true;
      extraOptions = [
        "--unsupported-gpu"
      ];

      config = {
        modifier = "Mod4";
      };
    };
  };

  gtk = {
    enable = true;
  };
}
