{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [../core.nix];

  home.username = "charles";
  home.homeDirectory = "/home/charles";

  programs = let
    dotFiles = ../dotfiles/charles;
  in {
    emacs = {
      enable = true;
      extraPackages = epkgs:
        with epkgs; [
          vterm
          treesit-grammars.with-all-grammars
        ];
    };

    bash = {
      enable = true;
      initExtra = ''
        set -o vi
        MAIL=/var/mail/$USER
      '';
    };

    git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        user = {
          name = "Charles Ellis";
          email = "hamled@hamled.dev";
        };
      };

      includes = [
        {
          condition = "gitdir:~/projects/cmdnctrl/";
          path = "~/projects/cmdnctrl/.gitconfig";
        }
      ];

      signing.format = null;
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = let
        defaults = {
          ForwardAgent = false;
          IdentitiesOnly = true;
        };
      in {
        "*" = {
          Compression = true;
          AddKeysToAgent = "3h";
        };

        "github.com" =
          defaults
          // {
            User = "git";
            IdentityFile = "~/.ssh/github_ed25519";
          };

        "gitlab_cnc" =
          defaults
          // {
            HostName = "gitlab.com";
            User = "git";
            IdentityFile = "~/.ssh/gitlab_cnc_ed25519";
          };

        "*.amazonaws.com" =
          defaults
          // {
            IdentityFile = "~/.ssh/aws_rsa4k";
            ForwardAgent = true;
          };
      };
    };

    alacritty = {
      enable = true;
      settings.font = let
        fontFamily = "DejaVu Sans Mono";
      in {
        size = 16.0;

        normal.family = fontFamily;
        bold.family = fontFamily;
        italic.family = fontFamily;
        bold_italic.family = fontFamily;
      };
    };

    firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };

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
    vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        mkhl.direnv
        dracula-theme.theme-dracula
        vscodevim.vim
        gitlab.gitlab-workflow
        redhat.java
        vscjava.vscode-java-pack
        vscjava.vscode-java-dependency
        vscjava.vscode-gradle
        vscjava.vscode-java-debug
        vscjava.vscode-java-test
        visualstudioexptteam.vscodeintellicode
      ];
    };
  };

  wayland = {
    windowManager.sway = {
      enable = true;
      extraOptions = ["--unsupported-gpu"];

      config = let
        fontsSetting = {
          names = ["DejaVu Sans Mono"];
          size = 16.0;
        };
      in {
        modifier = "Mod4";
        fonts = fontsSetting;
        terminal = "alacritty";
        menu = "${pkgs.wmenu}/bin/wmenu-run";

        keybindings = let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
          lib.mkOptionDefault {
            "${modifier}+BackSpace" = "exec ${pkgs.swaylock}/bin/swaylock";
            "${modifier}+Print" = "exec ${pkgs.grim}/bin/grim -o $(${pkgs.sway}/bin/swaymsg -t get_outputs | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name') ~/Screenshots/$(date +'%F_%T_grim.png')";
          };

        #bars = [{ fonts = fontsSetting; }];

        input = {"*" = {xkb_options = "ctrl:nocaps";};};

        seat = {seat0 = {xcursor_theme = "Adwaita";};};
      };

      # Include this as extra config rather than use the `config.floating` attribute
      # because we want to also disable floating for some windows
      extraConfig = ''
        for_window [app_id="Zoom"] floating enable
        for_window [app_id="Zoom" title="^Zoom Workplace"] floating disable
        for_window [app_id="Zoom" title="^Meeting"] floating disable
      '';

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

    gtk4.theme = null;
  };

  fonts.fontconfig.enable = true;

  services = {blueman-applet.enable = true;};

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
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  home.shellAliases.ssh = "TERM=xterm ssh";
  home.sessionPath = ["$HOME/.local/bin"];
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
    '';

    ".local/share/lombok.system.jar".source = "${pkgs.lombok}/share/java/lombok.jar";

    ".npmrc".text = ''
      prefix = ''${HOME}/.local/state/npm
    '';
  };

  home.packages = with pkgs; [
    # Send sway's log output to the journal (tagged sway) instead of the tty
    (lib.hiPrio (writeShellScriptBin "sway" ''
      exec ${systemd}/bin/systemd-cat --identifier=sway ${config.wayland.windowManager.sway.package}/bin/sway "$@"
    ''))

    wl-clipboard
    swaylock
    ripgrep
    slack
    pavucontrol
    grim
    zoom-us
    slurp
    google-chrome
    unzip
    jetbrains.idea
    nodejs
    bun
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
    mailutils
    claude-code
    claude-agent-acp
    wmenu

    awscli2
    kubectl

    # Language servers
    yaml-language-server
    vscode-langservers-extracted
    typescript
    typescript-language-server
    bash-language-server
    dockerfile-language-server
    #rust-analyzer
    shellcheck

    eslint
    prettier

    alejandra
    dockfmt
    black
    #rustfmt
  ];
}
