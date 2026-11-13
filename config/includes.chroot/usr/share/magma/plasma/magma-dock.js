// Magma Linux Plasma 6: compact application dock and macOS-style status area.
let dock = null;

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

    dock = panel;

    // The dock is for applications only; system controls live at the top.
    for (const widget of panel.widgets()) {
        if ([
            "org.kde.plasma.pager",
            "org.kde.plasma.showdesktop",
            "org.kde.plasma.marginsseparator",
            "org.kde.plasma.systemtray",
            "org.kde.plasma.digitalclock"
        ].includes(widget.type)) {
            widget.remove();
        }
    }

    const dockOrder = [
        "org.kde.plasma.kickoff",
        "org.kde.plasma.icontasks"
    ];
    let dockIndex = 0;
    for (const type of dockOrder) {
        const widget = dock.widgets(type)[0];
        if (widget) {
            widget.index = dockIndex++;
        }
    }

    dock.location = "bottom";
    dock.floating = true;
    dock.alignment = "center";
    dock.lengthMode = "fit";
    dock.height = 64;
    dock.hiding = "none";
    dock.offset = 0;
    dock.locked = true;
    print("Magma application dock configured");
    break;
}

if (dock) {
    // Reuse an existing top panel when one is already present.
    let topPanel = null;
    const allPanels = panels();
    for (const panel of allPanels) {
        if (panel.location === "top") {
            topPanel = panel;
            break;
        }
    }

    if (!topPanel) {
        topPanel = new Panel;
        topPanel.location = "top";
    }

    // Keep only the macOS-style status area and clock on the right.
    const statusTypes = [
        "org.kde.plasma.systemtray",
        "org.magma.controlcenter",
        "org.kde.plasma.digitalclock"
    ];
    for (const widget of topPanel.widgets()) {
        if (!statusTypes.includes(widget.type)) {
            widget.remove();
        }
    }

    for (const type of statusTypes) {
        if (topPanel.widgets(type).length === 0) {
            topPanel.addWidget(type);
        }
    }

    // System tray, Magma Control Center, then date and time.
    let statusIndex = 0;
    for (const type of statusTypes) {
        const widget = topPanel.widgets(type)[0];
        if (widget) {
            widget.index = statusIndex++;
        }
    }

    topPanel.location = "top";
    // Match the macOS status-bar layout: reserve a full-width strip at the
    // screen edge, but keep every widget grouped on the right.
    topPanel.alignment = "right";
    topPanel.lengthMode = "fill";
    topPanel.height = 28;
    topPanel.offset = 0;
    topPanel.hiding = "none";
    // A docked panel reserves screen space, so maximized windows do not
    // render underneath it. The Magma color scheme supplies light text/icons.
    topPanel.floating = false;
    topPanel.locked = true;

    print("Magma macOS-style top status area configured");
}
