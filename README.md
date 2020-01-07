# ApexCtl

### Control SteelSeries Apex keyboards on GNU/Linux!

*Rewrite of a utility with the [same name][ApexCtl], with some influence from [Apex-Macros][ApexMacros].*  
*Works with the SteelSeries Apex, Apex RAW, 350, 300 and M800 keyboards.*

 - [Dependencies](#dependencies)
 - [Build](#build)
 - [Installation](#installation)
 - [Usage](#usage)

## Dependencies

 - udev
 - make
 - pkgconf
 - hidapi

### Arch:

```
pacman -S --needed base-devel pkgconf hidapi
```

**TODO:** add more distros  
ApexCtl has been reported to work in Fedora ([#2][i2]) and Ubuntu ([#4][i4])

## Build

```
git clone https://github.com/AstroSnail/apexctl
cd apexctl
make
```

Options can be specified at the end of the `make` command. For example:
```
make ENABLE_DATA_PRINT=1 HIDAPI_IMPL=hidapi-hidraw
```
You can find the options and their defaults at the top of the Makefile.

## Installation

*All installation is done manually. You can create directories which are missing.*

Copy the `apexctl` binary into `/usr/local/sbin/`.

Copy `config/00-apex.hwdb` into `/etc/udev/hwdb.d/` and rename it to your preference.
Then run `udevadm hwdb --update` or `systemd-hwdb update`.
To apply immediately, run `udevadm trigger`.

Copy `config/00-apexctl.rules` into `/etc/udev/rules.d/` and rename it to your preference.

If you use Xorg, copy `config/00-apex.conf` into `/etc/X11/xorg.conf.d/` and rename it to your preference.

**TODO:** Rewrite [the old scripts][oldscripts]

## Usage

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

To help you configure your hotkeys, the key mappings are as follows:
<table>
	<thead>
		<tr><th>Key</th><th>Symbol</th></tr>
	</thead>
	<tbody>
		<tr><td>L1</td><td>XF86Launch5</td></tr>
		<tr><td>L2</td><td>XF86Launch6</td></tr>
		<tr><td>L3</td><td>XF86Launch7</td></tr>
		<tr><td>L4</td><td>XF86Launch8</td></tr>
		<tr><td>&#x2196;</td><td>XF86ScrollUp</td></tr>
		<tr><td>&#x2197;</td><td>XF86ScrollDown</td></tr>
		<tr><td>MX1</td><td>XF86AudioMedia</td></tr>
		<tr><td>MX2</td><td>XF86Display</td></tr>
		<tr><td>MX3</td><td>XF86KbdLightOnOff</td></tr>
		<tr><td>MX4</td><td>XF86KbdBrightnessDown</td></tr>
		<tr><td>MX5</td><td>XF86KbdBrightnessUp</td></tr>
		<tr><td>MX6</td><td>XF86Reply</td></tr>
		<tr><td>MX7</td><td>XF86MailForward</td></tr>
		<tr><td>MX8</td><td>XF86Save</td></tr>
		<tr><td>MX9</td><td>XF86Documents</td></tr>
		<tr><td>MX10</td><td>XF86Battery</td></tr>
		<tr><td>M1</td><td>XF86Launch1</td></tr>
		<tr><td>M2</td><td>XF86Launch2</td></tr>
		<tr><td>M3</td><td>XF86WWW</td></tr>
		<tr><td>M4</td><td>XF86DOS</td></tr>
		<tr><td>M5</td><td>XF86ScreenSaver</td></tr>
		<tr><td>M6</td><td>XF86RotateWindows</td></tr>
		<tr><td>M7</td><td>XF86TaskPane</td></tr>
		<tr><td>M8</td><td>XF86Mail</td></tr>
		<tr><td>M9</td><td>XF86Favorites</td></tr>
		<tr><td>M10</td><td>XF86MyComputer</td></tr>
		<tr><td>M11</td><td>XF86Back</td></tr>
		<tr><td>M12</td><td>XF86Forward</td></tr>
	</tbody>
</table>

[ApexCtl]: https://github.com/tuxmark5/ApexCtl
[ApexMacros]: https://github.com/Gibtnix/Apex-Macros
[i2]: https://github.com/AstroSnail/apexctl/issues/2
[i4]: https://github.com/AstroSnail/apexctl/issues/4
[oldscripts]: https://github.com/tuxmark5/ApexCtl/blob/master/makefile
