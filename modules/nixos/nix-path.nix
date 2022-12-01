{ channel, inputs, ... }: {
  nix.nixPath = [
    "nixpkgs=${channel.input}"
    "nixpkgs-latest=${inputs.latest}"
    "nixos-config=${../../lib/compat/nixos}"
    "home-manager=${inputs.home}"
  ];
}
