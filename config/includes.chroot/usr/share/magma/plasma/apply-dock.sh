#!/bin/sh
set -eu

SCRIPT="/usr/share/magma/plasma/magma-dock.js"
[ -s "$SCRIPT" ] || exit 0
command -v dbus-send >/dev/null 2>&1 || exit 0

# Plasma may not have finished starting when XDG autostart begins.
# The desktop session will run this helper on login; dbus-send invokes
# Plasma's supported scripting entry point without opening a console.
dbus-send --session --type=method_call --print-reply \
    --dest=org.kde.plasmashell \
    /PlasmaShell org.kde.PlasmaShell.evaluateScript \
    string:"$(cat "$SCRIPT")" >/dev/null 2>&1 || true
