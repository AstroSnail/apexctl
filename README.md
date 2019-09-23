# ApexCtl

### Control SteelSeries Apex and Apex RAW keyboards on GNU/Linux!

*Rewrite of a utility with the [same name](https://github.com/tuxmark5/ApexCtl), with some influence from [Apex-Macros](https://github.com/Gibtnix/Apex-Macros)*

 - [Dependencies](#deps)
 - [Build](#build)
 - [Installation](#install)
 - [Usage](#usage)
 - [Advanced XKB Configuration](#advanced)

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

Copy `config/steelseries` to `~/.xkb/symbols/`.
If you use X11, then add the following line to your `~/.xinitrc` (or any other startup file you use):
```
setxkbmap -print | sed '/xkb_symbols/s/"/+steelseries(apex)"/2' | xkbcomp -I"$HOME/.xkb" - $DISPLAY
```
You may adjust the `setxkbmap` command to your preference.
Adjust `steelseries(apex)` to your model if it exists in this file. (currently only apex exists)  
If you use a Wayland compositor that implements libxkbcommon, then configuring the compositor is up to you.  
**TODO:** add examples

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
  colors  Set colors and brightnesses per-zone.

Commands usage:
  probe  <numbers>            (up to 32 2-digit hex numbers)
  reboot                      (no arguments)
  keys   <on|off>             
  poll   <frequency>          (125, 250, 500, or 1000)
  bright <zone> <brightness>  (zone 1-5, brightness 1-8)
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

## <a id="advanced"></a> Advanced XKB Configuration

If you're familiar with XKB configuration files (this is beyond just setxkbmap), you might want to try making your own rules.
For example, a fairly minimal configuration might look like this:

`myrules`
```
! model    =  keycodes  types     compat
  *        =  evdev     complete  complete

! model    =  symbols
  *        =  pc+%l%(v)+compose(caps)
  apex300  = +steelseries(apex)

! model    =  geometry
  apex300  =  steelseries(apex300)
  *        =  pc(pc104)
```
`myrules.lst`
```
! model
  apex300  SteelSeries Apex 300 (Apex RAW)
```

Add these files to `~/.xkb/rules/`, and add the following line to your `~/.xinitrc` instead:
```
setxkbmap -I "$HOME/.xkb" -print -rules myrules | xkbcomp -I"$HOME/.xkb" - $DISPLAY
```

You may specify layout and variant in the `setxkbmap` command, but options (such as `compose:caps`) won't work. You will need to add those to the rules manually.
