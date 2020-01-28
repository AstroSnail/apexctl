#!/bin/sh -eu

BINDIR="${BINDIR:-/usr/local/sbin}"
UDEVHWDBDIR="${UDEVHWDBDIR:-/etc/udev/hwdb.d}"
UDEVRULESDIR="${UDEVRULESDIR:-/etc/udev/rules.d}"

USEXORG=${USEXORG:-}
DISPLAY=${DISPLAY:-}
XORGCONFDIR="${XORGCONFDIR:-/etc/X11/xorg.conf.d}"

apex_install () {(
	set -eux

	mkdir --parents "$BINDIR"
	install --mode=0755 apexctl "$BINDIR"/apexctl

	mkdir --parents "$UDEVHWDBDIR"
	install --mode=0644 config/default/00-apex.hwdb "$UDEVHWDBDIR"/90-apex.hwdb

	mkdir --parents "$UDEVRULESDIR"
	install --mode=0644 config/default/00-apexctl.rules "$UDEVRULESDIR"/90-apexctl.rules

	if [ "$USEXORG" = "y" ]
	then
		mkdir --parents "$XORGCONFDIR"
		install --mode=0644 config/default/00-apex.conf "$XORGCONFDIR"/90-apex.conf
	fi

	udevadm hwdb --update
	udevadm trigger
)}

apex_uninstall () {(
	set -eux

	rm --force "$BINDIR"/apexctl
	rm --force "$UDEVHWDBDIR"/90-apex.hwdb
	rm --force "$UDEVRULESDIR"/90-apexctl.rules
	rm --force "$XORGCONFDIR"/90-apex.conf

	udevadm hwdb --update
	udevadm trigger
)}

case ":$PATH:" in
	(*:"$BINDIR":*)
		;;
	(*)
		echo 'It appears `'"$BINDIR"\'' is not in your $PATH'
		echo 'Either add it to your $PATH in your shell profile,'
		echo 'or set $BINDIR to somewhere in your $PATH when you run this installer.'
		echo 'Example: sudo env BINDIR=/usr/sbin make install'
		exit 1
esac

action=apex_install
if [ "${1:-}" = -u ]; then action=apex_uninstall; shift; fi
if [ -z "$USEXORG" ] && [ -n "$DISPLAY" ]; then USEXORG=y; fi
$action
