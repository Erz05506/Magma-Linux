import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1280
    height: 720
    color: "#090a0d"

    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property string selectedUser: userModel.lastUser
    property bool userListVisible: false
    property string statusMessage: ""
    property color accent: "#ff7a1a"
    property string clockText: Qt.formatDateTime(new Date(), "HH:mm")
    property string dateText: Qt.formatDateTime(new Date(), "dddd, d MMMM")

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
        }
    }

    Column {
        id: loginContent
        width: Math.min(360, root.width * 0.8)
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.height * 0.055
        spacing: 0

        Rectangle {
            width: 82
            height: 82
            radius: 41
            color: "#17191e"
            border.width: 1
            border.color: "#a84d1d"
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                anchors.centerIn: parent
                width: 66
                height: 66
                source: Qt.resolvedUrl("assets/magma-flame.png")
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }

        Item { width: 1; height: 15 }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.selectedUser.length > 0 ? root.selectedUser : "Choose a user"
            color: "#f1f2f4"
            font.pixelSize: 24
            font.weight: Font.Medium
        }

        Item { width: 1; height: 7 }

        Item {
            width: parent.width
            height: 24

            Text {
                anchors.centerIn: parent
                text: "List users  ▾"
                color: "#aeb5c0"
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.userListVisible = !root.userListVisible
            }
        }

        Rectangle {
            width: parent.width
            height: root.userListVisible ? Math.min(150, userModel.count * 36) : 0
            visible: root.userListVisible
            color: "#171c24"
            radius: 8
            border.color: "#343c48"
            clip: true

            ListView {
                anchors.fill: parent
                model: userModel
                delegate: Rectangle {
                    width: ListView.view.width
                    height: 36
                    color: userRowMouse.containsMouse ? "#2b303a" : "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        text: model.name
                        color: "#e5e8ed"
                        font.pixelSize: 13
                    }
                    MouseArea {
                        id: userRowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedUser = model.name
                            root.userListVisible = false
                            passwordInput.text = ""
                            passwordInput.forceActiveFocus()
                        }
                    }
                }
            }
        }

        Item { width: 1; height: 7 }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Enter your password"
            color: "#929aa6"
            font.pixelSize: 13
        }

        Item { width: 1; height: 26 }

        Rectangle {
            id: passwordField
            width: parent.width
            height: 54
            radius: 9
            color: "#17191e"
            border.width: 1
            border.color: passwordInput.activeFocus ? accent : "#34343a"

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
            }

            TextInput {
                id: passwordInput
                anchors.left: parent.left
                anchors.right: submitArea.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 17
                anchors.rightMargin: 8
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

                Keys.onReturnPressed: sddm.login(root.selectedUser, passwordInput.text, sessionIndex)
                Keys.onEnterPressed: sddm.login(root.selectedUser, passwordInput.text, sessionIndex)
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

            Rectangle {
                id: submitArea
                width: 40
                height: 40
                radius: 20
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                color: submitMouse.containsMouse ? "#ff7a1a" : "#303139"

                Canvas {
                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = submitMouse.containsMouse ? "#17191e" : "#f1f2f4"
                        ctx.lineWidth = 1.9
                        ctx.lineCap = "round"
                        ctx.lineJoin = "round"
                        ctx.beginPath()
                        ctx.moveTo(3, 11)
                        ctx.lineTo(18, 11)
                        ctx.moveTo(12, 5)
                        ctx.lineTo(18, 11)
                        ctx.lineTo(12, 17)
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.moveTo(14, 3)
                        ctx.lineTo(19, 3)
                        ctx.lineTo(19, 19)
                        ctx.lineTo(14, 19)
                        ctx.stroke()
                    }
                }

                MouseArea {
                    id: submitMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.login(root.selectedUser, passwordInput.text, sessionIndex)
                }
            }
        }

        Item { width: 1; height: 12 }

        Text {
            id: statusText
            width: parent.width
            text: root.statusMessage
            color: "#ff9a62"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            visible: text.length > 0
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 34
        anchors.bottomMargin: 28
        spacing: 10

        Rectangle {
            width: 44
            height: 44
            radius: 22
            color: sleepMouse.containsMouse ? "#29313c" : "#171c24"
            border.width: 1
            border.color: "#3a4655"
            opacity: sddm.canSuspend ? 1.0 : 0.4

            Text {
                anchors.centerIn: parent
                text: "Zz"
                color: "#d9dde3"
                font.pixelSize: 15
                font.weight: Font.Medium
            }

            MouseArea {
                id: sleepMouse
                anchors.fill: parent
                enabled: sddm.canSuspend
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.suspend()
            }
        }

        Rectangle {
            width: 44
            height: 44
            radius: 22
            color: shutdownMouse.containsMouse ? "#29313c" : "#171c24"
            border.width: 1
            border.color: "#3a4655"
            opacity: sddm.canPowerOff ? 1.0 : 0.4

            Canvas {
                anchors.centerIn: parent
                width: 20
                height: 20
                onPaint: {
                    var c = getContext("2d")
                    c.reset()
                    c.strokeStyle = "#d9dde3"
                    c.lineWidth = 1.8
                    c.lineCap = "round"
                    c.beginPath()
                    c.arc(10, 11, 7, 0.25 * Math.PI, 2.75 * Math.PI, false)
                    c.stroke()
                    c.beginPath()
                    c.moveTo(10, 1)
                    c.lineTo(10, 10)
                    c.stroke()
                }
            }

            MouseArea {
                id: shutdownMouse
                anchors.fill: parent
                enabled: sddm.canPowerOff
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }

        Rectangle {
            width: 44
            height: 44
            radius: 22
            color: rebootMouse.containsMouse ? "#29313c" : "#171c24"
            border.width: 1
            border.color: "#3a4655"

            Canvas {
                anchors.centerIn: parent
                width: 20
                height: 20
                onPaint: {
                    var c = getContext("2d")
                    c.reset()
                    c.strokeStyle = "#d9dde3"
                    c.fillStyle = "#d9dde3"
                    c.lineWidth = 1.8
                    c.lineCap = "round"
                    c.lineJoin = "round"
                    c.beginPath()
                    c.arc(10, 10, 7, 0.15 * Math.PI, 1.85 * Math.PI, false)
                    c.stroke()
                    c.beginPath()
                    c.moveTo(15.5, 3.5)
                    c.lineTo(16, 8)
                    c.lineTo(11.5, 7.5)
                    c.stroke()
                }
            }

            MouseArea {
                id: rebootMouse
                anchors.fill: parent
                enabled: sddm.canReboot
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
