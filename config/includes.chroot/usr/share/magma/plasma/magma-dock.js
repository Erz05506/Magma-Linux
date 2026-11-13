// Magma Linux Plasma 6: compact application dock and macOS-style status area.
let dock = null;

for (const id of panelIds) {
    const panel = panelById(id);
    if (!panel) {
        continue;
    }

    const widgets = panel.widgets();
    let hasTaskManager = false;
    for (const widget of widgets) {
        if (widget.type === "org.kde.plasma.icontasks") {
            hasTaskManager = true;
            break;
        }
    }
    if (!hasTaskManager) {
        continue;
    }

    dock = panel;

    // The bottom dock contains application launchers only.
    for (const widget of panel.widgets()) {
        if (widget.type !== "org.kde.plasma.icontasks") {
            widget.remove();
        }
    }

    const taskManager = dock.widgets("org.kde.plasma.icontasks")[0];
    if (taskManager) {
        taskManager.index = 0;
    }

    dock.location = "bottom";
    // A non-floating panel reserves desktop space so windows never sit behind the dock.
    dock.floating = false;
    dock.alignment = "center";
    dock.lengthMode = "fit";
    dock.height = 68;
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
    const spacerType = "org.kde.plasma.panelspacer";
    for (const widget of topPanel.widgets()) {
        if (!statusTypes.includes(widget.type) && widget.type !== spacerType) {
            widget.remove();
        }
    }

    if (topPanel.widgets(spacerType).length === 0) {
        topPanel.addWidget(spacerType);
    }
    for (const type of statusTypes) {
        if (topPanel.widgets(type).length === 0) {
            topPanel.addWidget(type);
        }
    }

    // The flexible spacer pushes the complete status group to the right edge.
    const spacer = topPanel.widgets(spacerType)[0];
    if (spacer) {
        spacer.index = 0;
    }

    // System tray, Magma Control Center, then date and time.
    let statusIndex = 1;
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
