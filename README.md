# ApexCtl

### Control SteelSeries Apex keyboards on GNU/Linux!

*Rewrite of a utility with the [same name][ApexCtl], with some influence from [Apex-Macros][ApexMacros].*  
*Works with the SteelSeries Apex, Apex RAW, 350 and 300, with attempted support of the M800 and Apex 3 keyboards.*  
**This probably won't work with the newer SteelSeries Apex keyboards.**
**There is no real method of adding support for them at this time.**
**If you know how to figure out USB protocols or somebody who does, help would be GREATLY appreciated.**

 - [Dependencies](#dependencies)
 - [Build](#build)
 - [Installation](#installation)
 - [Usage](#usage)
 - [Advanced](#advanced)

[ApexCtl]: https://github.com/tuxmark5/ApexCtl
[ApexMacros]: https://github.com/Gibtnix/Apex-Macros

## Dependencies

 - udev
 - make
 - pkgconf
 - hidapi

### Arch:

```
pacman -S --needed base-devel hidapi
```

**TODO:** Add more distros  
ApexCtl has been reported to work in Fedora ([#2][i2]) and Ubuntu ([#4][i4])

[i2]: https://github.com/AstroSnail/apexctl/issues/2
[i4]: https://github.com/AstroSnail/apexctl/issues/4

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

```
sudo make install
```

**Maual installation is no longer supported. You may still try, but it's probably not worth it**  
~~Installation may also be done manually. The instructions are as follows.~~  
~~You should create directories which are missing on your system.~~

 - ~~Copy the `apexctl` binary into `/usr/local/sbin/`. (or anywhere in your $PATH)~~

 - ~~Copy `config/default/00-apex.hwdb` into `/etc/udev/hwdb.d/` and rename it to your preference.~~
 - - ~~Then run `udevadm hwdb --update` or `systemd-hwdb update`.~~
 - - ~~To apply immediately, run `udevadm trigger`.~~

 - ~~Copy `config/default/00-apexctl.rules` into `/etc/udev/rules.d/` and rename it to your preference.~~

 - ~~If you use Xorg, copy `config/default/00-apex.conf` into `/etc/X11/xorg.conf.d/` and rename it to your preference.~~
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

To help you configure your hotkeys, the default key mappings are as follows:
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

If you you use Xorg and you don't like these mappings, you can change them up
with the provided `config/extra/Xmodmap` file. Copy this file to `~/.Xmodmap`
(or append its contents if it already exists) and add `xmodmap ~/.Xmodmap` to
your init file. (usually `~/.xinitrc`) (**TODO:** Some display managers
automatically load `~/.Xmodmap`? Which ones?)

If you do this the key mappings will instead be as follows:

<table>
	<thead>
		<tr><th>Key</th><th>Symbol</th></tr>
	</thead>
	<tbody>
		<tr><td>L1</td><td>XF86Launch1</td></tr>
		<tr><td>L2</td><td>XF86Launch2</td></tr>
		<tr><td>L3</td><td>XF86Launch3</td></tr>
		<tr><td>L4</td><td>XF86Launch4</td></tr>
		<tr><td>&#x2196;</td><td>XF86Back</td></tr>
		<tr><td>&#x2197;</td><td>XF86Forward</td></tr>
		<tr><td>MX1</td><td>F25</td></tr>
		<tr><td>MX2</td><td>F26</td></tr>
		<tr><td>MX3</td><td>F27</td></tr>
		<tr><td>MX4</td><td>F28</td></tr>
		<tr><td>MX5</td><td>F29</td></tr>
		<tr><td>MX6</td><td>F30</td></tr>
		<tr><td>MX7</td><td>F31</td></tr>
		<tr><td>MX8</td><td>F32</td></tr>
		<tr><td>MX9</td><td>F33</td></tr>
		<tr><td>MX10</td><td>F34</td></tr>
		<tr><td>M1</td><td>F13</td></tr>
		<tr><td>M2</td><td>F14</td></tr>
		<tr><td>M3</td><td>F15</td></tr>
		<tr><td>M4</td><td>F16</td></tr>
		<tr><td>M5</td><td>F17</td></tr>
		<tr><td>M6</td><td>F18</td></tr>
		<tr><td>M7</td><td>F19</td></tr>
		<tr><td>M8</td><td>F20</td></tr>
		<tr><td>M9</td><td>F21</td></tr>
		<tr><td>M10</td><td>F22</td></tr>
		<tr><td>M11</td><td>F23</td></tr>
		<tr><td>M12</td><td>F24</td></tr>
	</tbody>
</table>

You can modify `config/extra/Xmodmap` to your preference before you install it.

If you use Wayland and you don't like the default mappings, you'll have more
luck with the Advanced configuration below.

## Advanced

If you want more control over the mappings (or plain don't like xmodmap)
there is a way using XKB, but it'll take some work, skill, and probably luck.

~~In `config/extra/` you'll find a different `00-apex.hwdb` and some extra files.~~

 - ~~Install `00-apex.hwdb` as described in [Installation](#installation)~~

 - ~~Make a new directory `~/.xkb/` and copy `config/extra/rules/` and `config/extra/symbols/` into it.~~

 - `sudo make install-advanced`
 - `ln -s /etc/X11/xkb ~/.xkb`

 - If you use Xorg, add `setxkbmap -I "$HOME/.xkb" -print -rules apex | xkbcomp -I"$HOME/.xkb" - "$DISPLAY"` to an init file. (usually `~/.xinitrc`)
 - - You can modify the setxkbmap command to your liking. For example: `setxkbmap -I "$HOME/.xkb" -print -rules apex us colemak compose:menu`
 - - If you want to use different options, you'll need to modify the files in `config/extra/rules/`. They have instructions inside.
 - - If you use another keyboard layout manager, it's up to you to figure out how to make it work.

 - If you use Wayland, your compositor will need to implement libxkbcommon, and it's up to you to configure it. (**TODO:** Add examples)

Once you're done, the key mappings will now be like the second table above. If
you wish to use different mappings, you can modify
`config/extra/symbols/steelseries` before you install it.

Be aware that Xorg appears to only support F-keys up to F35.
