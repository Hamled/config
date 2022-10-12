{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [ binutils coreutils curl git gptfdisk ];
  };

  nix = {
    systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    useSandbox = true;

    gc.automatic = true;
    autoOptimiseStore = true;
    optimise.automatic = true;

    trustedUsers = [ "root" "@wheel" ];
    allowedUsers = [ "@wheel" ];

    extraOptions = ''
      min-free = ${512 * 1024 * 1024}
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';
  };
}
