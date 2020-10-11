#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

LITBIAD=${LITBIAD:-$BINDIR/litbiad}
LITBIACLI=${LITBIACLI:-$BINDIR/litbia-cli}
LITBIATX=${LITBIATX:-$BINDIR/litbia-tx}
LITBIAQT=${LITBIAQT:-$BINDIR/qt/litbia-qt}

[ ! -x $LITBIAD ] && echo "$LITBIAD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
LTAVER=($($LITBIACLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for litbiad if --version-string is not set,
# but has different outcomes for litbia-qt and litbia-cli.
echo "[COPYRIGHT]" > footer.h2m
$LITBIAD --version | sed -n '1!p' >> footer.h2m

for cmd in $LITBIAD $LITBIACLI $LITBIATX $LITBIAQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${LTAVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${LTAVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
