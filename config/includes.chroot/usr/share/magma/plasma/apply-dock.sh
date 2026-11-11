#!/bin/sh
set -eu

SCRIPT="/usr/share/magma/plasma/magma-dock.js"
[ -s "$SCRIPT" ] || exit 0
command -v dbus-send >/dev/null 2>&1 || exit 0

# Wait briefly for the Plasma D-Bus service after login.
attempt=0
while [ "$attempt" -lt 5 ]; do
    if dbus-send --session --type=method_call --print-reply \
        --dest=org.kde.plasmashell \
        /PlasmaShell org.kde.PlasmaShell.evaluateScript \
        string:"$(cat "$SCRIPT")" >/dev/null 2>&1; then
        exit 0
    fi
    attempt=$((attempt + 1))
    sleep 2
done

exit 0
