// Magma Linux Plasma 6: compact application dock and top system area.
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

    dock.location = "floating";
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

    const topTypes = [
        "org.kde.plasma.digitalclock",
        "org.kde.plasma.systemtray",
        "org.kde.plasma.lock_logout"
    ];
    for (const type of topTypes) {
        if (topPanel.widgets(type).length === 0) {
            topPanel.addWidget(type);
        }
    }

    topPanel.location = "top";
    topPanel.alignment = "right";
    topPanel.lengthMode = "fit";
    topPanel.height = 30;
    // Reserve the top strip like macOS: maximized windows start below it.
    // "windowsgobelow" lets maximized windows extend behind the panel.
    topPanel.hiding = "none";
    topPanel.offset = 8;

    // Keep the system controls visually light; applets that support this
    // hint will not draw their own individual backgrounds.
    for (const widget of topPanel.widgets()) {
        widget.userBackgroundHints = "none";
    }
    topPanel.locked = true;
    print("Magma top system area configured");
}
