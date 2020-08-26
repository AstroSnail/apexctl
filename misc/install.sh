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
: "${UDEVRELOAD:=y}"

apex_install () {
  install -D -m0755 -- apexctl "${BINDIR}/apexctl"
  install -D -m0644 -- 00-apexctl.rules "${UDEVRULESDIR}/90-apexctl.rules"

  if [ "${ADVANCED}" = "y" ]
  then
    install -D -m0644 -- 00-apex-advanced.hwdb "${UDEVHWDBDIR}/90-apex.hwdb"
    install -D -m0644 -- xkb/rules/apex "${XKBDIR}/rules/apex"
    install -D -m0644 -- xkb/rules/apex.lst "${XKBDIR}/rules/apex.lst"
    install -D -m0644 -- xkb/symbols/steelseries "${XKBDIR}/symbols/steelseries"
  else
    install -D -m0644 -- 00-apex.hwdb "${UDEVHWDBDIR}/90-apex.hwdb"
  fi

  if [ "${USEXORG}" = "y" ]
  then
    install -D -m0644 -- 00-apex.conf "${XORGCONFDIR}/90-apex.conf"
  fi

  if [ "${UDEVRELOAD}" = "y" ]
  then
    udevadm hwdb --update
    udevadm trigger
  fi
}

apex_uninstall () {
  rm -f -- \
    "${BINDIR}/apexctl" \
    "${UDEVHWDBDIR}/90-apex.hwdb" \
    "${UDEVRULESDIR}/90-apexctl.rules" \
    "${XORGCONFDIR}/90-apex.conf" \
    "${XKBDIR}/rules/apex" \
    "${XKBDIR}/rules/apex.lst" \
    "${XKBDIR}/symbols/steelseries"

  if [ "${UDEVRELOAD}" = "y" ]
  then
    udevadm hwdb --update
    udevadm trigger
  fi
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
