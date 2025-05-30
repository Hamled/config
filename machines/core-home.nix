{
  config,
  inputs,
  usersHome,
  ...
}: {
  imports = [
    inputs.home.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = inputs;
      home-manager.sharedModules = [
        {
          home.sessionVariables = {
            NIX_PATH =
              config.environment.sessionVariables.NIX_PATH or config.environment.variables.NIX_PATH;
          };

          xdg.configFile."nix/registry.json".text =
            config.environment.etc."nix/registry.json".text;
        }
      ];
      home-manager.users = usersHome;
    }
  ];
}
