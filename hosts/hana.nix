{ modulesPath, profiles, suites, lib, pkgs, config, ... }: {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    profiles.users.charles
  ] ++ suites.base;

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
  services.openssh.enable = true;

  programs = {
    dconf.enable = true;
  };

  xdg = {
    icons.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    gnome.adwaita-icon-theme
  ];

  security.polkit.enable = true;

  # Networking
  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "thunderbolt" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "i915" ];
  boot.kernelParams = [ "i915.force_probe=4688"];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  # Root is encrypted
  boot.initrd.luks.devices.sys.device = "/dev/disk/by-uuid/b5b67eb0-d597-4d5c-80fd-952be392ed0b";

  # File systems

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7f502911-f8f9-49d8-b3eb-eb0e4b52842b";
    fsType = "ext4";
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/7FC7-7714";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/fd16660e-0edd-4603-a17a-50a5d0336c23"; }
  ];

  # Hardware configuration
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    trackpoint = {
      enable = true;
      device = "TPPS/2 Elan TrackPoint";
    };

    opengl.enable = true;
    nvidiaOptimus.disable = true;
  };
}
