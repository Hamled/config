{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./hardware.nix];

  # Nix configuration
  system.stateVersion = "22.05";

  # System configuration
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # Keyboard / console
  services.xserver = {
    xkb = {
      layout = "us";
      options = "ctrl:nocaps";
    };

    videoDrivers = ["modesetting"];
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Programs & Services
  services = {
    resolved.enable = true;
    openssh.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    blueman.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
    gnome = {
      gnome-keyring.enable = true;
      at-spi2-core.enable = true;
    };
    speechd.enable = true;
    pulseaudio = {
      extraModules = [pkgs.pulseaudio-modules-bt];
      package = pkgs.pulseaudioFull;
    };
  };

  programs = {
    dconf.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };

  xdg = {
    icons.enable = true;
    portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [xdg-desktop-portal-gtk];
      config.common.default = "*";
    };
  };
  # Create a symlink in /usr/libexec because Zoom expects it
  systemd.tmpfiles.rules = [
    "L+ /usr/libexec/xdg-desktop-portal - - - - ${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal"
  ];

  fonts = {
    fontconfig.enable = true;

    packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.iosevka
      nerd-fonts.fira-mono
      nerd-fonts.fira-code
      nerd-fonts.ubuntu-sans
      nerd-fonts.ubuntu-mono
      corefonts
      vistafonts
      noto-fonts
    ];
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker = let
    rootless = false;

    docker-config = {
      enable = true;

      daemon.settings = {
        default-ulimits = {
          nofile = {
            Name = "nofile";
            Hard = 64000;
            Soft = 64000;
          };
        };
      };
    };
  in
    {}
    // (
      if rootless
      then {rootless = docker-config;}
      else docker-config
    );

  environment.systemPackages = with pkgs; [
    vim
    wget
    adwaita-icon-theme
    qt5.qtwayland
    pulseaudioFull
    orca
  ];

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  # Allow delegation in user services
  systemd.packages = [
    (pkgs.runCommandNoCC "delegate.conf" {
        preferLocalBuild = true;
        allowSubstitutes = false;
      } ''
        dropInDir=$out/etc/systemd/system/user@.service.d
        mkdir -p $dropInDir
        echo "[Service]" >> $dropInDir/delegate.conf
        echo "Delegate=yes" >> $dropInDir/delegate.conf
      '')
  ];

  # Networking
  networking = {
    hostName = "hana";
    useDHCP = lib.mkDefault true;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };
}
