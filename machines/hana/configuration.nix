{ config, lib, pkgs, ... }: {
  imports = [ ./hardware.nix ];

  # Nix configuration
  system.stateVersion = "22.05";

  # System configuration
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # Keyboard / console
  services.xserver = {
    layout = "us";
    xkbOptions = "ctrl:nocaps";

    videoDrivers = [ "modesetting" ];
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Programs & Services
  services = {
    openssh.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    blueman.enable = true;
  };

  programs = {
    dconf.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  xdg = {
    icons.enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
    };
  };

  fonts = {
    fontconfig.enable = true;

    fonts = with pkgs; [ nerdfonts ];
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
  in { } // (if rootless then { rootless = docker-config; } else docker-config);

  environment.systemPackages = with pkgs; [
    vim
    wget
    gnome.adwaita-icon-theme
    qt5.qtwayland
    pulseaudioFull
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
