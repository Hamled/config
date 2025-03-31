{ pkgs, lib, config, ... }: {
  imports = [ ../core.nix ];

  home.username = "charles";
  home.homeDirectory = "/home/charles";

  programs = let dotFiles = ../dotfiles/charles;
  in {
    emacs = {
      enable = true;
      extraPackages = epkgs: [ epkgs.vterm ];
      extraConfig = ''
        (after! lsp-java
          (setq
            lsp-java-java-path "${pkgs.jdk}/lib/openjdk/bin/java"

            lsp-java-configuration-runtimes '[
              (:name "JavaSE-1.8" :path "${pkgs.jdk8}/lib/openjdk")
              (:name "JavaSE-11" :path "${pkgs.jdk11}/lib/openjdk")
              (:name "JavaSE-17" :path "${pkgs.jdk17}/lib/openjdk")
            ]

            lsp-java-vmargs
            `(,@lsp-java-vmargs
              "-javaagent:/home/charles/.local/share/lombok.jar")

            lsp-java-import-gradle-java-home "${pkgs.jdk11}/lib/openjdk"
          ))
      '';
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
      userEmail = "hamled@hamled.dev";

      includes = [
        {
          condition = "gitdir:~/projects/si/";
          path = "~/projects/si/.gitconfig";
        }
        {
          condition = "gitdir:~/projects/cmdnctrl/";
          path = "~/projects/cmdnctrl/.gitconfig";
        }
      ];

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
          forwardAgent = true;
        };

        AdaWeb-Live = defaults // {
          host = "ada-web-live";
          hostname = "adadevelopersacademy.org";
          user = "bitnami";
          identityFile = "~/.ssh/ada_live_ed25519";
        };

        AdaWeb-Old = defaults // {
          host = "ada-web-old";
          hostname = "old.adadevelopersacademy.org";
          user = "bitnami";
          identityFile = "~/.ssh/ada_old_ed25519";
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

    direnv = {
      config.global = {
        strict_env = true;
        hide_env_diff = true;
        warn_timeout = "5m";
      };
      stdlib = ''
        # Skip direnv if DIRENV_DISABLE is set
        ''${DIRENV_DISABLE:+exit}

        use_flake_unfree() {
          watch_file flake.nix
          watch_file flake.lock
          mkdir -p "$(direnv_layout_dir)"
          eval "$(NIXPKGS_ALLOW_UNFREE=1 nix print-dev-env --impure --profile "$(direnv_layout_dir)/flake-profile" "$@")"
        }

        layout_poetry() {
          if [[ ! -f ./pyproject.toml ]]; then
            log_error 'No pyproject.toml found. Use `poetry new` or `poetry init` to create one.'
            exit 2
          fi

          # Ensure project dependencies are present
          poetry install -q

          # Set virtual env from poetry
          export VIRTUAL_ENV="$(poetry env info --path)"

          # Run python layout
          layout_python
        }
     '';
    };
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

        #bars = [{ fonts = fontsSetting; }];

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
      package = pkgs.gnome-themes-extra;
      name = "Adwaita";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
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

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  home.shellAliases.ssh = "TERM=xterm ssh";
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.file = {
    ".local/bin/firefox-personal" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
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
      org.gradle.java.installations.paths=${
        lib.concatMapStringsSep "," (p: "${p}/lib/openjdk")
        (with pkgs; [ jdk8 jdk11 jdk17 jdk ])
      }
    '';

    ".local/share/lombok.system.jar".source =
      "${pkgs.lombok}/share/java/lombok.jar";
  };

  home.packages = with pkgs; let
    jdk8-low = jdk8.overrideAttrs (oldAttrs: { meta.priority = 10; });
    zoom-us-fix = zoom-us.overrideAttrs (attrs: {
      nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [pkgs.bbe];
      postFixup =
        ''
          cp $out/opt/zoom/zoom .
          bbe -e 's/\0manjaro\0/\0nixos\0\0\0/' < zoom > $out/opt/zoom/zoom
        ''
        + (attrs.postFixup or "")
        + ''
          sed -i 's|Exec=|Exec=env XDG_CURRENT_DESKTOP="gnome" |' $out/share/applications/Zoom.desktop
        '';
    });
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
      zoom-us-fix
      slurp
      google-chrome
      unzip
      jetbrains.idea-ultimate
      nodejs
      dbeaver-bin
      whois
      jq
      xh
      rustup
      devenv
      discord
      cloudflare-warp
      postman
      cachix
      virt-manager
      sbcl
      guile
      pandoc

      # Language servers
      jdt-language-server
      yaml-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.bash-language-server
      #rust-analyzer
      shellcheck

      nodePackages.eslint
      nodePackages.prettier

      alejandra
      dockfmt
      black
      #rustfmt
    ];
}
