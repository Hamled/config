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

    alacritty.enable = true;
    firefox.enable = true;
  };

  wayland = {
    windowManager.sway = {
      enable = true;
      extraOptions = [
        "--unsupported-gpu"
      ];

      config = {
        modifier = "Mod4";
        terminal = "alacritty";

        seat = {
          seat0 = {
              xcursor_theme = "Adwaita";
          };
        };
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita";
    };

    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
  };
}
