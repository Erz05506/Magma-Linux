// Magma Linux Plasma 6 dock layout.
for (const id of panelIds) {
    const panel = panelById(id);
    if (!panel) {
        continue;
    }

    const widgets = panel.widgets();
    let hasLauncher = false;
    for (const widget of widgets) {
        if (widget.type === "org.kde.plasma.kickoff") {
            hasLauncher = true;
            break;
        }
    }
    if (!hasLauncher) {
        continue;
    }

    // Remove desktop-navigation controls that do not belong in the dock.
    for (const widget of panel.widgets()) {
        if ([
            "org.kde.plasma.pager",
            "org.kde.plasma.showdesktop",
            "org.kde.plasma.marginsseparator"
        ].includes(widget.type)) {
            widget.remove();
        }
    }

    // Keep the launcher, pinned/running apps, tray and clock in one compact row.
    const order = [
        "org.kde.plasma.kickoff",
        "org.kde.plasma.icontasks",
        "org.kde.plasma.systemtray",
        "org.kde.plasma.digitalclock"
    ];
    let index = 0;
    for (const type of order) {
        const widget = panel.widgets(type)[0];
        if (widget) {
            widget.index = index++;
        }
    }

    panel.location = "floating";
    panel.alignment = "center";
    panel.lengthMode = "fit";
    panel.height = 58;
    panel.hiding = "none";
    panel.offset = 0;
    panel.locked = true;
    print("Magma Dock configured on panel " + id);
    break;
}
