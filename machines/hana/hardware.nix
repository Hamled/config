{
  config,
  lib,
  pkgs,
  ...
}: {
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "thunderbolt" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = ["dm-snapshot" "i915"];
  boot.kernelParams = ["i915.force_probe=4688"];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];
  # Root is encrypted
  boot.initrd.luks.devices.sys.device = "/dev/disk/by-uuid/b5b67eb0-d597-4d5c-80fd-952be392ed0b";

  # Custom udev rules for stage 1
  boot.initrd.extraUdevRulesCommands = let
    hana-initrd-udev-rules = pkgs.callPackage ./packages/initrd-udev-rules/default.nix {
      inherit pkgs;
    };
  in ''
    cp -v ${hana-initrd-udev-rules}/lib/udev/rules.d/*.rules $out/
  '';

  # File systems
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7f502911-f8f9-49d8-b3eb-eb0e4b52842b";
    fsType = "ext4";
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/7FC7-7714";
    fsType = "vfat";
  };

  swapDevices = [{device = "/dev/disk/by-uuid/fd16660e-0edd-4603-a17a-50a5d0336c23";}];

  # Hardware configuration
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware = {
    cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
    trackpoint = {
      enable = true;
      device = "TPPS/2 Elan TrackPoint";
    };

    graphics.enable = true;
    nvidiaOptimus.disable = true;

    bluetooth.enable = true;
  };
}
