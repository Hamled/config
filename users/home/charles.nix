{ suites, pkgs, lib, config, ... }: {
  imports = suites.base;

  programs = let dotFiles = ../dotfiles/charles;
  in {
    doom-emacs = {
      enable = true;
      doomPrivateDir = "${dotFiles}/doom.d";
    };

    bash = {
      enable = true;
      initExtra = ''
        set -o vi
      '';
    };

    git = {
      enable = true;
      userName = "Charles Ellis";
      userEmail = "cellis@securityinnovation.com";

      includes = [{
        condition = "gitdir:~/projects/personal/";
        contents = { user.email = "hamled@hamled.dev"; };
      }];

      extraConfig.init.defaultBranch = "main";
    };

    ssh = {
      enable = true;

      matchBlocks = let
        defaults = {
          forwardAgent = false;
          identitiesOnly = true;
        };
      in {
        GitHub = defaults // {
          host = "github.com";
          user = "git";
          identityFile = "~/.ssh/github_ed25519";
        };

        GitLab = defaults // {
          host = "gitlab.com";
          user = "git";
          identityFile = "~/.ssh/gitlab_ed25519";
        };
      };
    };

    alacritty = {
      enable = true;
      settings.font = let fontFamily = "DejaVu Sans Mono";
      in {
        size = 16.0;

        normal.family = fontFamily;
        bold.family = fontFamily;
        italic.family = fontFamily;
        bold_italic.family = fontFamily;
      };
    };

    firefox.enable = true;
  };

  wayland = {
    windowManager.sway = {
      enable = true;
      extraOptions = [ "--unsupported-gpu" ];

      config = let
        fontsSetting = {
          names = [ "DejaVu Sans Mono" ];
          size = 16.0;
        };
      in {
        modifier = "Mod4";
        fonts = fontsSetting;
        terminal = "alacritty";

        keybindings =
          let modifier = config.wayland.windowManager.sway.config.modifier;
          in lib.mkOptionDefault {
            "${modifier}+BackSpace" = "exec ${pkgs.swaylock}/bin/swaylock";
          };

        bars = [{ fonts = fontsSetting; }];

        input = { "*" = { xkb_options = "ctrl:nocaps"; }; };

        seat = { seat0 = { xcursor_theme = "Adwaita"; }; };
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

  fonts.fontconfig.enable = true;

  xdg.configFile."swaylock/config".text = ''
    color=0f0f0f
  '';

  home.packages = with pkgs; [
    wl-clipboard
    swaylock
    jdk
    jdt-language-server
    nixfmt
  ];
}
