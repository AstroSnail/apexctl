{ pkgs ? import <nixpkgs> { } }: pkgs.stdenv.mkDerivation {
  name = "apexctl";
  src = builtins.path {
    name = "apexctl";
    path = ./.;
  };
  buildInputs = [ pkgs.hidapi ];
  preBuild = ''
    buildFlagsArray+=(CC=gcc)
    buildFlagsArray+=(CPPLIBS="''${NIX_CFLAGS_COMPILE}")
    buildFlagsArray+=(LDFLAGS=-Wl,"$(tr -s ' ' , <<<"''${NIX_LDFLAGS}")")
    buildFlagsArray+=(LDLIBS=-lhidapi-libusb)
    buildFlagsArray+=(HIDAPI_LONG_INCLUDE=1)
  '';
  preInstall = ''
    export BINDIR="$out/bin"
    export UDEVHWDBDIR="$out/etc/udev/hwdb.d"
    export UDEVRULESDIR="$out/etc/udev/rules.d"
    export USEXORG=y
    export XORGCONFDIR="$out/etc/X11/xorg.conf.d"
    export IHAVEANALLTERRAINVEHICLE=y
    export UDEVRELOAD=n
  '';
}
