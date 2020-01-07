#!/bin/sh -e

BINDIR="${BINDIR:-"/usr/local/sbin"}"
UDEVHWDBDIR="${UDEVHWDBDIR:-"/etc/udev/hwdb.d"}"
UDEVRULESDIR="${UDEVRULESDIR:-"/etc/udev/rules.d"}"

USEXORG="$USEXORG"
XORGCONFDIR="${XORGCONFDIR:-"/etc/X11/xorg.conf.d"}"

cd "$(dirname "$0")"

install () {(
	set -ex

	mkdir -p "$BINDIR"
	mkdir -p "$UDEVHWDBDIR"
	mkdir -p "$UDEVRULESDIR"
	if [ "$USEXORG" = "y" ]; then mkdir -p "$XORGCONFDIR"; fi

	cp apexctl "$BINDIR/apexctl"
	cp config/00-apex.hwdb "$UDEVHWDBDIR/90-apex.hwdb"
	cp config/00-apexctl.rules "$UDEVRULESDIR/90-apexctl.rules"
	if [ "$USEXORG" = "y" ]; then cp config/00-apex.conf "$XORGCONFDIR/90-apex.conf"; fi

	udevadm hwdb --update
	udevadm trigger
)}

uninstall () {(
	set -ex

	rm -f "$BINDIR/apexctl"
	rm -f "$UDEVHWDBDIR/90-apex.hwdb"
	rm -f "$UDEVRULESDIR/90-apexctl.rules"
	rm -f "$XORGCONFDIR/90-apex.conf"

	udevadm hwdb --update
	udevadm trigger
)}

action=install
if [ "$1" = "-u" ]; then action=uninstall; fi

if [ -n "$DISPLAY" ]; then USEXORG=y; fi

case ":$PATH:" in
	(*:"$BINDIR":*)
		;;
	(*)
		echo 'It appears '"BINDIR"' is not in your $PATH'
		echo 'Either add it to your $PATH in your shell profile,'
		echo 'or set $BINDIR to somewhere in your $PATH when you run this installer.'
		echo 'Example: BINDIR=/usr/sbin ./install.sh'
		exit 1
esac

$action
