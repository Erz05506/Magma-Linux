import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1280
    height: 720
    color: "#090a0d"

    property int sessionIndex: sessionBox.index
    property string statusMessage: ""
    property color accent: "#ff7a1a"
    property string clockText: Qt.formatDateTime(new Date(), "HH:mm")
    property string dateText: Qt.formatDateTime(new Date(), "dddd, d MMMM")

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            root.statusMessage = ""
        }

        function onLoginFailed() {
            passwordInput.text = ""
            root.statusMessage = "Incorrect password"
            passwordInput.forceActiveFocus()
        }

        function onInformationMessage(message) {
            root.statusMessage = message
        }
    }

    // Quiet, wallpaper-like background: no app-style login card.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#11151d" }
            GradientStop { position: 0.55; color: "#0b0d12" }
            GradientStop { position: 1.0; color: "#08090c" }
        }
    }

    Rectangle {
        width: Math.min(root.width * 0.62, 820)
        height: width
        radius: width / 2
        color: "#ff7a1a"
        opacity: 0.035
        x: root.width * 0.52
        y: -height * 0.48
    }

    Rectangle {
        width: Math.min(root.width * 0.42, 560)
        height: width
        radius: width / 2
        color: "#547da8"
        opacity: 0.045
        x: -width * 0.28
        y: root.height * 0.48
    }

    // Time and date are part of the desktop environment, not a login panel.
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.max(48, root.height * 0.105)
        spacing: 7

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.clockText
            color: "#f1f2f4"
            font.pixelSize: Math.min(76, root.height * 0.105)
            font.weight: Font.Light
            font.letterSpacing: 1
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.dateText
            color: "#9ba2ad"
            font.pixelSize: 15
            font.weight: Font.Normal
        }
    }

    Column {
        id: loginContent
        width: Math.min(340, root.width * 0.78)
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.height * 0.055
        spacing: 0

        Rectangle {
            width: 76
            height: 76
            radius: 38
            color: "#202630"
            border.width: 1
            border.color: "#343c48"
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                anchors.centerIn: parent
                width: 43
                height: 43
                source: Qt.resolvedUrl("assets/magma-flame.png")
                fillMode: Image.PreserveAspectFit
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 17
            text: userModel.lastUser.length > 0 ? userModel.lastUser : "Welcome"
            color: "#f1f2f4"
            font.pixelSize: 23
            font.weight: Font.Medium
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 7
            text: "Enter your password to unlock"
            color: "#929aa6"
            font.pixelSize: 13
        }

        Item { width: 1; height: 27 }

        Rectangle {
            id: passwordField
            width: parent.width
            height: 52
            radius: 8
            color: "#171c24"
            border.width: passwordInput.activeFocus ? 1 : 1
            border.color: passwordInput.activeFocus ? accent : "#343c48"

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
            }

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: 17
                anchors.rightMargin: 17
                verticalAlignment: TextInput.AlignVCenter
                color: "#f1f2f4"
                selectionColor: accent
                selectedTextColor: "#111318"
                font.pixelSize: 15
                echoMode: TextInput.Password
                passwordCharacter: "●"
                selectByMouse: true
                clip: true
                focus: true

                Keys.onReturnPressed: sddm.login(userModel.lastUser, passwordInput.text, sessionIndex)
                Keys.onEnterPressed: sddm.login(userModel.lastUser, passwordInput.text, sessionIndex)
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 17
                anchors.verticalCenter: parent.verticalCenter
                text: "Password"
                color: "#747e8b"
                font.pixelSize: 14
                visible: passwordInput.text.length === 0
            }
        }

        Text {
            id: statusText
            width: parent.width
            anchors.topMargin: 12
            text: root.statusMessage
            color: "#ff9a62"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            visible: text.length > 0
        }

        Rectangle {
            id: loginButton
            width: parent.width
            height: 46
            radius: 8
            color: loginMouse.containsMouse ? "#ff8b35" : accent
            anchors.topMargin: 18

            Text {
                anchors.centerIn: parent
                text: "Sign in"
                color: "#111318"
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            MouseArea {
                id: loginMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.login(userModel.lastUser, passwordInput.text, sessionIndex)
            }
        }

        Item { width: 1; height: 24 }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12

            ComboBox {
                id: sessionBox
                width: 170
                height: 34
                model: sessionModel
                index: sessionModel.lastIndex
                font.pixelSize: 11
            }

            LayoutBox {
                id: layoutBox
                width: 82
                height: 34
                visible: keyboard.enabled && keyboard.layouts.length > 1
                font.pixelSize: 11
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 34
        anchors.bottomMargin: 28
        spacing: 10

        Rectangle {
            width: 42
            height: 42
            radius: 21
            color: shutdownMouse.containsMouse ? "#29313c" : "#171c24"
            border.width: 1
            border.color: "#343c48"

            Text {
                anchors.centerIn: parent
                text: "⏻"
                color: "#d9dde3"
                font.pixelSize: 19
            }

            MouseArea {
                id: shutdownMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }

        Rectangle {
            width: 42
            height: 42
            radius: 21
            color: rebootMouse.containsMouse ? "#29313c" : "#171c24"
            border.width: 1
            border.color: "#343c48"

            Text {
                anchors.centerIn: parent
                text: "↻"
                color: "#d9dde3"
                font.pixelSize: 20
            }

            MouseArea {
                id: rebootMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot()
            }
        }
    }

    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 30
        anchors.bottomMargin: 37
        text: "MAGMA LINUX"
        color: "#68717e"
        font.pixelSize: 11
        font.letterSpacing: 2
        font.weight: Font.DemiBold
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.clockText = Qt.formatDateTime(new Date(), "HH:mm")
            root.dateText = Qt.formatDateTime(new Date(), "dddd, d MMMM")
        }
    }

    Component.onCompleted: passwordInput.forceActiveFocus()
}
