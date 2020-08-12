#!/bin/sh
set -eu

: "${BINDIR:=/usr/local/sbin}"
: "${UDEVHWDBDIR:=/etc/udev/hwdb.d}"
: "${UDEVRULESDIR:=/etc/udev/rules.d}"

: "${USEXORG:=}"
: "${DISPLAY:=}"
: "${XORGCONFDIR:=/etc/X11/xorg.conf.d}"

: "${ADVANCED:=n}"
: "${XKBDIR:=/etc/X11/xkb}"

: "${IHAVEANALLTERRAINVEHICLE:=n}"

apex_install () {
	install -d -- "${BINDIR}" "${UDEVHWDBDIR}" "${UDEVRULESDIR}"
	install -m0755 -- apexctl "${BINDIR}/apexctl"
	install -m0644 -- config/default/00-apexctl.rules "${UDEVRULESDIR}/90-apexctl.rules"

	if [ "${ADVANCED}" = "y" ]
	then
		install -d -- "${XKBDIR}/rules" "${XKBDIR}/symbols"
		install -m0644 -- config/extra/00-apex.hwdb "${UDEVHWDBDIR}/90-apex.hwdb"
		install -m0644 -- config/extra/rules/apex "${XKBDIR}/rules/apex"
		install -m0644 -- config/extra/rules/apex.lst "${XKBDIR}/rules/apex.lst"
		install -m0644 -- config/extra/symbols/steelseries "${XKBDIR}/symbols/steelseries"
	else
		install -m0644 -- config/default/00-apex.hwdb "${UDEVHWDBDIR}/90-apex.hwdb"
	fi

	if [ "${USEXORG}" = "y" ]
	then
		install -d -- "${XORGCONFDIR}"
		install -m0644 -- config/default/00-apex.conf "${XORGCONFDIR}/90-apex.conf"
	fi

	udevadm hwdb --update
	udevadm trigger
}

apex_uninstall () {
	rm -f -- "${BINDIR}/apexctl"
	rm -f -- "${UDEVHWDBDIR}/90-apex.hwdb"
	rm -f -- "${UDEVRULESDIR}/90-apexctl.rules"
	rm -f -- "${XORGCONFDIR}/90-apex.conf"
	rm -f -- "${XKBDIR}/rules/apex"
	rm -f -- "${XKBDIR}/rules/apex.lst"
	rm -f -- "${XKBDIR}/symbols/steelseries"

	udevadm hwdb --update
	udevadm trigger
}

if [ "${IHAVEANALLTERRAINVEHICLE}" != "y" ]
then
	case ":${PATH}:" in
		(*:"${BINDIR}":*)
			;;
		(*)
			echo "It appears \`${BINDIR}' is not in your \$PATH."
			echo "Either add it to your \$PATH in your shell profile, or set"
			echo "\$BINDIR to a path in your \$PATH when you run this installer."
			echo "Example: sudo env BINDIR=/usr/sbin make install"
			exit 1
	esac
fi

action=apex_install
if [ "${1:-}" = -u ]; then action=apex_uninstall; shift; fi
if [ -z "${USEXORG}" ] && [ -n "${DISPLAY}" ]; then USEXORG=y; fi

set -x
"${action}"
