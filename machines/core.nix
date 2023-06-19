{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      git
      gptfdisk
      lsof
      vim
      wget
      htop

      man
      man-pages
      man-pages-posix
    ];
  };

  users.mutableUsers = true;

  nixpkgs.config.allowUnfree = true;
  nix = {
    systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    useSandbox = true;

    gc.automatic = true;
    autoOptimiseStore = true;
    optimise.automatic = true;

    trustedUsers = [ "root" "@wheel" ];
    allowedUsers = [ "@wheel" ];

    extraOptions = ''
      min-free = ${toString (512 * 1024 * 1024)}
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';
  };

  hardware.enableRedistributableFirmware = true;
}
