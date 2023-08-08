{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "hana-initrd-udev-rules";
  src = ./rules/.;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/lib/udev/rules.d

    # Raid disks do not work with systemd >250 checking diskseq???
    cp 01-md-ignore-diskseq.rules $out/lib/udev/rules.d
  '';
}
