import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    width: 34
    height: 30

    property bool wifiEnabled: false
    property bool wifiAvailable: false
    property bool bluetoothEnabled: false
    property bool bluetoothAvailable: false
    property var pendingCommands: ({})

    function runCommand(command, callback) {
        pendingCommands[command] = callback
        commandRunner.connectSource(command)
    }

    function refreshStatus() {
        runCommand("nmcli -t -f WIFI radio", function(output, exitCode) {
            wifiAvailable = exitCode === 0
            wifiEnabled = output.trim() === "enabled"
        })

        runCommand("bluetoothctl show", function(output, exitCode) {
            bluetoothAvailable = exitCode === 0 && output.indexOf("Controller") !== -1
            bluetoothEnabled = bluetoothAvailable && output.indexOf("Powered: yes") !== -1
        })
    }

    function toggleWifi() {
        if (!wifiAvailable)
            return
        const command = "nmcli radio wifi " + (wifiEnabled ? "off" : "on")
        runCommand(command, function() { refreshStatus() })
    }

    function toggleBluetooth() {
        if (!bluetoothAvailable)
            return
        const command = "bluetoothctl power " + (bluetoothEnabled ? "off" : "on")
        runCommand(command, function() { refreshStatus() })
    }

    function openSettings(moduleName) {
        runCommand("systemsettings " + moduleName, function() {})
    }

    Component.onCompleted: refreshStatus()

    Plasma5Support.DataSource {
        id: commandRunner
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            const callback = root.pendingCommands[source]
            if (callback)
                callback(data["stdout"] || "", Number(data["exit code"]))
            delete root.pendingCommands[source]
            disconnectSource(source)
        }
    }

    compactRepresentation: Item {
        implicitWidth: 34
        implicitHeight: 30

        PlasmaCore.IconItem {
            anchors.centerIn: parent
            width: 18
            height: 18
            source: "view-filter"
        }
    }

    fullRepresentation: Item {
        implicitWidth: 360
        implicitHeight: 414

        Rectangle {
            anchors.fill: parent
            radius: 18
            color: "#151519"
            border.color: "#303036"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 2

                        Controls.Label {
                            text: "Control Center"
                            color: "#ffffff"
                            font.pixelSize: 19
                            font.weight: Font.DemiBold
                        }

                        Controls.Label {
                            text: "Magma Linux"
                            color: "#92929a"
                            font.pixelSize: 11
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: "#ff7a1a"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 112
                        radius: 14
                        color: root.wifiEnabled ? "#352318" : "#202025"
                        border.color: root.wifiEnabled ? "#75401f" : "#303036"

                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 14
                            anchors.rightMargin: 12
                            spacing: 8

                            PlasmaCore.IconItem {
                                width: 23
                                height: 23
                                source: "network-wireless"
                            }

                            Controls.Label {
                                text: "Wi-Fi"
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                            }

                            Controls.Label {
                                text: !root.wifiAvailable ? "Unavailable" : (root.wifiEnabled ? "On" : "Off")
                                color: "#b8b8bf"
                                font.pixelSize: 11
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: root.wifiAvailable
                            onClicked: root.toggleWifi()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 112
                        radius: 14
                        color: root.bluetoothEnabled ? "#352318" : "#202025"
                        border.color: root.bluetoothEnabled ? "#75401f" : "#303036"

                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 14
                            anchors.rightMargin: 12
                            spacing: 8

                            PlasmaCore.IconItem {
                                width: 23
                                height: 23
                                source: "bluetooth"
                            }

                            Controls.Label {
                                text: "Bluetooth"
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                            }

                            Controls.Label {
                                text: !root.bluetoothAvailable ? "Unavailable" : (root.bluetoothEnabled ? "On" : "Off")
                                color: "#b8b8bf"
                                font.pixelSize: 11
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: root.bluetoothAvailable
                            onClicked: root.toggleBluetooth()
                        }
                    }
                }

                Controls.Label {
                    text: "QUICK SETTINGS"
                    color: "#888891"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    Layout.topMargin: 2
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    radius: 11
                    color: "#202025"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        PlasmaCore.IconItem {
                            width: 19
                            height: 19
                            source: "notifications"
                        }

                        Controls.Label {
                            Layout.fillWidth: true
                            text: "Focus & notifications"
                            color: "#f0f0f2"
                            font.pixelSize: 12
                        }

                        PlasmaCore.IconItem {
                            width: 16
                            height: 16
                            source: "go-next"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.openSettings("kcm_notifications")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    radius: 11
                    color: "#202025"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        PlasmaCore.IconItem {
                            width: 19
                            height: 19
                            source: "preferences-desktop-display"
                        }

                        Controls.Label {
                            Layout.fillWidth: true
                            text: "Display settings"
                            color: "#f0f0f2"
                            font.pixelSize: 12
                        }

                        PlasmaCore.IconItem {
                            width: 16
                            height: 16
                            source: "go-next"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.openSettings("kcm_kscreen")
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true

                    Controls.Label {
                        text: "System controls"
                        color: "#777780"
                        font.pixelSize: 10
                    }

                    Item { Layout.fillWidth: true }

                    Controls.Button {
                        text: "Refresh"
                        font.pixelSize: 11
                        onClicked: root.refreshStatus()
                    }
                }
            }
        }
    }
}