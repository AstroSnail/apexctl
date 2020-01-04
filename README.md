# ApexCtl

### Control SteelSeries Apex and Apex RAW keyboards on GNU/Linux!

*Rewrite of a utility with the [same name](https://github.com/tuxmark5/ApexCtl), with some influence from [Apex-Macros](https://github.com/Gibtnix/Apex-Macros)*

 - [Dependencies](#deps)
 - [Build](#build)
 - [Installation](#install)
 - [Usage](#usage)

## <a id="deps"></a> Dependencies

 - hidapi
 - libusb (if the hidapi-hidraw implementation is unavailable or broken)
 - pkgconf

### Arch:

```
pacman -S --needed hidapi pkgconf
```

### Fedora:

```
yum install hidapi-devel pkgconf
```

**TODO:** add more distros

## <a id="build"></a> Build

```
git clone https://github.com/AstroSnail/apexctl
cd apexctl
make
```

Options can be specified after the `make` command. For example:
```
make ENABLE_DATA_PRINT=1 HIDAPI_IMPL=hidapi-hidraw
```
You can find the options and their defaults at the top of the Makefile.

## <a id="install"></a> Installation

*All installation is done manually.*  
**TODO:** Rewrite [the old scripts](https://github.com/tuxmark5/ApexCtl/blob/master/makefile)

Copy the `apexctl` binary to `/usr/local/sbin/`.

Copy `config/00-apex.hwdb` to `/etc/udev/hwdb.d/` and rename it to your preference.
Then run `udevadm hwdb --update` or `systemd-hwdb update`.
To apply immediately, run `udevadm trigger`.

Copy `config/00-apexctl.rules` to `/etc/udev/rules.d/` and rename it to your preference.

If you use X11, copy `config/00-apex.conf` to `/etc/X11/xorg.conf.d/` and rename it to your preference.

## <a id="usage"></a> Usage

```
$ apexctl
Usage: apexctl <command> [arguments...]

Commands:
  probe   Probe for new commands.
  reboot  Reboot the keyboard.
  keys    Enable or disable extra keys.
  poll    Set polling frequency.
  bright  Set backlight brightness.
  save    [NEW&BUGGY] Save state changed since keyboard power-on
  colors  Set colors and brightnesses per-zone.

Commands usage:
  probe  <numbers>            (up to 32 2-digit hex numbers)
  reboot                      (no arguments)
  keys   <on|off>             
  poll   <frequency>          (125, 250, 500, or 1000)
  bright <zone> <brightness>  (zone 1-5, brightness 1-8)
  save                        (no arguments)
  colors <colors>             (see below)

Color specification:
  Up to 5 colors can be specified.
  They set south, east, north, west and logo zones, in that order.
  The formats are case-insensitive.

  Format   Example  Meaning
  RRGGBBA  ABCDEF4  Sets color to triplet #ABCDEF and brightness to 4 (from 1 to 8)
  RRGGBB   ABCDEF   Equivalent to ABCDEF8
  RGBA     ACE4     Equivalent to AACCEE4
  RGB      ACE      Equivalent to AACCEE8
  A        4        Equivalent to FFFFFF4
  0                 SPECIAL: Does not affect the zone
```

The key mappings are as follows:
Key | Symbol
---:|:---
L1 | XF86Launch5
L2 | XF86Launch6
L3 | XF86Launch7
L4 | XF86Launch8
M1 | XF86Launch1
M2 | XF86Launch2
M3 | XF86WWW
M4 | XF86DOS
M5 | XF86ScreenSaver
M6 | XF86RotateWindows
M7 | XF86TaskPane
M8 | XF86Mail
M9 | XF86Favorites
M10 | XF86MyComputer
M11 | XF86Back
M12 | XF86Forward
MX1 | XF86MonBrightnessDown
MX2 | XF86MonBrightnessUp
MX3 | XF86AudioMedia
MX4 | XF86Display
MX5 | XF86KbdLightOnOff
MX6 | XF86KbdBrightnessDown
MX7 | XF86KbdBrightnessUp
MX8 | XF86Send
MX9 | XF86Reply
MX10 | XF86MailForward
