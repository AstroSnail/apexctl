#!/bin/sh -eu

: "${BINDIR:=/usr/local/sbin}"
: "${UDEVHWDBDIR:=/etc/udev/hwdb.d}"
: "${UDEVRULESDIR:=/etc/udev/rules.d}"

: "${USEXORG:=}"
: "${DISPLAY:=}"
: "${XORGCONFDIR:=/etc/X11/xorg.conf.d}"

apex_install () {
	mkdir -p "${BINDIR}"
	install -m0755 apexctl "${BINDIR}/apexctl"

	mkdir -p "${UDEVHWDBDIR}"
	install -m0644 config/default/00-apex.hwdb "${UDEVHWDBDIR}/90-apex.hwdb"

	mkdir -p "${UDEVRULESDIR}"
	install -m0644 config/default/00-apexctl.rules "${UDEVRULESDIR}/90-apexctl.rules"

	if [ "${USEXORG}" = "y" ]
	then
		mkdir -p "${XORGCONFDIR}"
		install -m0644 config/default/00-apex.conf "${XORGCONFDIR}/90-apex.conf"
	fi

	udevadm hwdb --update
	udevadm trigger
}

apex_uninstall () {
	rm -f "${BINDIR}/apexctl"
	rm -f "${UDEVHWDBDIR}/90-apex.hwdb"
	rm -f "${UDEVRULESDIR}/90-apexctl.rules"
	rm -f "${XORGCONFDIR}/90-apex.conf"

	udevadm hwdb --update
	udevadm trigger
}

case ":${PATH}:" in
	(*:"${BINDIR}":*)
		;;
	(*)
		echo "It appears \`${BINDIR}' is not in your \$PATH"
		echo "Either add it to your \$PATH in your shell profile,"
		echo "or set \$BINDIR to somewhere in your \$PATH when you run this installer."
		echo "Example: sudo env BINDIR=/usr/sbin make install"
		exit 1
esac

action=apex_install
if [ "${1:-}" = -u ]; then action=apex_uninstall; shift; fi
if [ -z "${USEXORG}" ] && [ -n "${DISPLAY}" ]; then USEXORG=y; fi

set -x
"${action}"
