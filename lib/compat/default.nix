let
  lock = builtins.fromJSON (builtins.readFile ../../flake.lock);
  node-name = lock.nodes.root.inputs.flake-compat;
  rev = lock.nodes.${node-name}.locked.rev;
  flake = (import (fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${rev}.tar.gz";
    sha256 = "0zd3x46fswh5n6faq4x2kkpy6p3c6j593xbdlbsl40ppkclwc80x";
  }) { src = ../../.; });
in flake
