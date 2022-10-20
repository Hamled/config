{ suites, pkgs, ... }: {
  imports = suites.base;

  programs = {
    bash = {
      enable = true;
      initExtra = ''
        set -o vi
      '';
    };

    ssh = {
      enable = true;

      matchBlocks = let
        defaults = {
          forwardAgent = false;
          identitiesOnly = true;
        }; in {
        GitHub = defaults // {
          host = "github.com";
          user = "git";
          identityFile = "~/.ssh/github_ed25519";
        };
      };
    };
  };
}
