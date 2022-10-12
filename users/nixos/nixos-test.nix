{ ... }: {
  users.users.nixos = {
    password = "password";
    description = "NixOS test user";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
