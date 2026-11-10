import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1280
    height: 720
    color: "#0a0a0c"

    property int sessionIndex: sessionBox.index
    property string statusMessage: ""
    property color accent: "#ff7a1a"
    property string clockText: Qt.formatDateTime(new Date(), "ddd, dd MMM  •  HH:mm")

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            root.statusMessage = ""
        }

        function onLoginFailed() {
            passwordInput.text = ""
            root.statusMessage = "Incorrect password. Please try again."
            passwordInput.forceActiveFocus()
        }

        function onInformationMessage(message) {
            root.statusMessage = message
        }
    }

    Rectangle {
        width: 520
        height: 520
        radius: width / 2
        color: accent
        opacity: 0.055
        anchors.centerIn: parent
    }

    Rectangle {
        width: 420
        height: 540
        radius: 24
        color: "#131316"
        border.width: 1
        border.color: "#29292f"
        anchors.centerIn: parent

        Image {
            id: magmaLogo
            source: Qt.resolvedUrl("assets/magma-flame.png")
            width: 76
            height: 76
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 34
        }

        Text {
            text: "MAGMA"
            color: "#f5f5f7"
            font.pixelSize: 27
            font.weight: Font.DemiBold
            font.letterSpacing: 4
            anchors.top: magmaLogo.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Welcome back"
            color: "#a5a5ad"
            font.pixelSize: 14
            anchors.top: parent.top
            anchors.topMargin: 158
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "USERNAME"
            color: "#a5a5ad"
            font.pixelSize: 10
            font.letterSpacing: 1.4
            anchors.left: parent.left
            anchors.leftMargin: 42
            anchors.top: parent.top
            anchors.topMargin: 202
        }

        Rectangle {
            id: usernameField
            height: 46
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 42
            anchors.rightMargin: 42
            anchors.top: parent.top
            anchors.topMargin: 222
            radius: 9
            color: "#1c1c21"
            border.width: userInput.activeFocus ? 1 : 0
            border.color: accent

            TextInput {
                id: userInput
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                verticalAlignment: TextInput.AlignVCenter
                color: "#f5f5f7"
                selectionColor: accent
                selectedTextColor: "#0a0a0c"
                font.pixelSize: 14
                text: userModel.lastUser
                selectByMouse: true
                clip: true

                Keys.onReturnPressed: passwordInput.forceActiveFocus()
                Keys.onEnterPressed: passwordInput.forceActiveFocus()
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "Username"
                color: "#777780"
                font.pixelSize: 14
                visible: userInput.text.length === 0
            }
        }

        Text {
            text: "PASSWORD"
            color: "#a5a5ad"
            font.pixelSize: 10
            font.letterSpacing: 1.4
            anchors.left: parent.left
            anchors.leftMargin: 42
            anchors.top: parent.top
            anchors.topMargin: 284
        }

        Rectangle {
            id: passwordField
            height: 46
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 42
            anchors.rightMargin: 42
            anchors.top: parent.top
            anchors.topMargin: 304
            radius: 9
            color: "#1c1c21"
            border.width: passwordInput.activeFocus ? 1 : 0
            border.color: accent

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                verticalAlignment: TextInput.AlignVCenter
                color: "#f5f5f7"
                selectionColor: accent
                selectedTextColor: "#0a0a0c"
                font.pixelSize: 14
                echoMode: TextInput.Password
                passwordCharacter: "●"
                selectByMouse: true
                clip: true

                Keys.onReturnPressed: sddm.login(userInput.text, passwordInput.text, sessionIndex)
                Keys.onEnterPressed: sddm.login(userInput.text, passwordInput.text, sessionIndex)
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "Password"
                color: "#777780"
                font.pixelSize: 14
                visible: passwordInput.text.length === 0
            }
        }

        Text {
            id: statusText
            text: root.statusMessage
            color: "#ff9a62"
            font.pixelSize: 11
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 36
            anchors.rightMargin: 36
            anchors.top: parent.top
            anchors.topMargin: 358
            visible: text.length > 0
        }

        Rectangle {
            id: loginButton
            height: 46
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 42
            anchors.rightMargin: 42
            anchors.top: parent.top
            anchors.topMargin: 388
            radius: 9
            color: loginMouse.containsMouse ? "#ff8b35" : accent

            Text {
                anchors.centerIn: parent
                text: "Sign in"
                color: "#0a0a0c"
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            MouseArea {
                id: loginMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sddm.login(userInput.text, passwordInput.text, sessionIndex)
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 454
            spacing: 10

            ComboBox {
                id: sessionBox
                width: 150
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

        Text {
            text: root.clockText
            color: "#777780"
            font.pixelSize: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        spacing: 12

        Rectangle {
            width: 42
            height: 42
            radius: 21
            color: shutdownMouse.containsMouse ? "#29292f" : "#17171b"
            border.width: 1
            border.color: "#29292f"

            Text {
                anchors.centerIn: parent
                text: "⏻"
                color: "#d8d8dc"
                font.pixelSize: 19
            }

            MouseArea {
                id: shutdownMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sddm.powerOff()
            }
        }

        Rectangle {
            width: 42
            height: 42
            radius: 21
            color: rebootMouse.containsMouse ? "#29292f" : "#17171b"
            border.width: 1
            border.color: "#29292f"

            Text {
                anchors.centerIn: parent
                text: "↻"
                color: "#d8d8dc"
                font.pixelSize: 20
            }

            MouseArea {
                id: rebootMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sddm.reboot()
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.clockText = Qt.formatDateTime(new Date(), "ddd, dd MMM  •  HH:mm")
    }

    Component.onCompleted: {
        if (userInput.text.length === 0)
            userInput.forceActiveFocus()
        else
            passwordInput.forceActiveFocus()
    }
}
