{ stdenv, lib, hidapi, advanced ? false }:

stdenv.mkDerivation {
  name = "apexctl";
  src = builtins.path {
    name = "apexctl-src";
    path = ./.;
  };
  buildInputs = [ hidapi ];
  preBuild = ''
    export BINDIR="$out/bin"
    buildFlagsArray+=(CC=gcc)
    buildFlagsArray+=(CPPLIBS="''${NIX_CFLAGS_COMPILE}")
    buildFlagsArray+=(LDFLAGS=-Wl,"$(tr -s ' ' , <<<"''${NIX_LDFLAGS}")")
    buildFlagsArray+=(LDLIBS=-lhidapi-libusb)
    buildFlagsArray+=(HIDAPI_LONG_INCLUDE=1)
  '' + lib.optionalString advanced ''
    buildFlagsArray+=(all-advanced)
  '';
  preInstall = ''
    export BINDIR="$out/bin"
    export UDEVHWDBDIR="$out/etc/udev/hwdb.d"
    export UDEVRULESDIR="$out/etc/udev/rules.d"
    export USEXORG=y
    export XORGCONFDIR="$out/etc/X11/xorg.conf.d"
    export XKBDIR="$out/share/X11/xkb"
    export IHAVEANALLTERRAINVEHICLE=y
    export UDEVRELOAD=n
  '';
  installTargets = if advanced then "install-advanced" else "install";
  meta = {
    description = "A program to control SteelSeries Apex keyboards";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
