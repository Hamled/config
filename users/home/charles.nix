{ suites, pkgs, lib, config, ... }: {
  imports = suites.base;

  programs = let dotFiles = ../dotfiles/charles;
  in {
    doom-emacs = {
      enable = true;
      doomPrivateDir = "${dotFiles}/doom.d";
      extraConfig = ''
        (after! lsp-java
          (setq
            lsp-java-vmargs
            `(,@lsp-java-vmargs
              "-javaagent:${pkgs.lombok}/share/java/lombok.jar"
              "-Xbootclasspath/a:${pkgs.lombok}/share/java/lombok.jar")))
      '';
      extraPackages = with pkgs; [ lombok ];
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

      ignores = [ ".dir-locals.el" ".projectile" ];

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

        AWS = defaults // {
          host = "*.amazonaws.com";
          identityFile = "~/.ssh/aws_rsa4k";
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
            "${modifier}+Print" =
              "exec ${pkgs.grim}/bin/grim -o $(${pkgs.sway}/bin/swaymsg -t get_outputs | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name') ~/Screenshots/$(date +'%F_%T_grim.png')";
          };

        bars = [{ fonts = fontsSetting; }];

        input = { "*" = { xkb_options = "ctrl:nocaps"; }; };

        seat = { seat0 = { xcursor_theme = "Adwaita"; }; };
      };

      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        # needs qt5.qtwayland in systemPackages
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
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

  services = { blueman-applet.enable = true; };

  xdg.configFile = {
    "swaylock/config".text = ''
      color=0f0f0f
    '';

    "xdg-desktop-portal-wlr/config".text = ''
      chooser_type = simple
      chooser_cmd = slurp -f %o ro
    '';
  };

  home.sessionPath = [ "$HOME/.local/bin" ];
  home.file = {
    ".local/bin/firefox-personal" = {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash
        exec ${pkgs.firefox}/bin/firefox -P personal "$@"
      '';
    };

    ".local/bin/firefox-idea".source = "${pkgs.firefox}/bin/firefox";

    ".local/bin/rust-analyzer" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        exec $(${pkgs.rustup}/bin/rustup which rust-analyzer) "$@"
      '';
    };

    ".gradle/gradle.properties".text = ''
      org.gradle.java.installations.auto-download=false
      org.gradle.java.installations.paths=${pkgs.jdk8}/lib/openjdk,${pkgs.jdk}/lib/openjdk
    '';
  };

  home.packages = with pkgs;
    let jdk8-low = jdk8.overrideAttrs (oldAttrs: { meta.priority = 10; });
    in [
      wl-clipboard
      swaylock
      jdk
      jdk8-low
      ripgrep
      slack
      bitwarden
      pavucontrol
      grim
      zoom-us
      slurp
      openvpn
      google-chrome
      unzip
      jetbrains.idea-ultimate
      nodejs
      dbeaver
      whois
      jq
      xh
      rustup

      # Language servers
      jdt-language-server
      yaml-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.typescript
      nodePackages.typescript-language-server
      #rust-analyzer
      nodePackages.eslint
      nodePackages.prettier
      nixfmt
      #rustfmt
    ];
}
