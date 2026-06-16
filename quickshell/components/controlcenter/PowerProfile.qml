import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    Layout.fillWidth: true
    height: 70

    radius: 10
    color: "#252538"

    // 0 = Saver
    // 1 = Balanced
    // 2 = Performance
    property int profile: 1

    readonly property var icons: [
        "󰌪",
        "󰾅",
        "󰓅"
    ]

    readonly property var profileNames: [
        "power-saver",
        "balanced",
        "performance"
    ]

    readonly property color accentColor:
        profile === 0 ? "#a6e3a1" :
        profile === 1 ? "#89b4fa" :
                        "#fab387"

    Process {
        id: setProfile

        command: [
            "powerprofilesctl",
            "set",
            profileNames[root.profile]
        ]
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        spacing: 12

        Rectangle {
            width: 46
            height: 46
            radius: 6

            color: Qt.rgba(
                root.accentColor.r,
                root.accentColor.g,
                root.accentColor.b,
                0.12
            )

            Text {
                anchors.centerIn: parent

                text: ""
                color: root.accentColor
                font.pixelSize: 20
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                id: track

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right

                height: 6
                radius: 3

                color: "#313244"

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter

                    height: parent.height
                    radius: parent.radius

                    width: thumb.x + thumb.width / 2

                    color: Qt.rgba(
                        root.accentColor.r,
                        root.accentColor.g,
                        root.accentColor.b,
                        0.35
                    )

                    Behavior on width {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Rectangle {
                    id: thumb

                    width: 34
                    height: 34
                    radius: 17

                    y: -(height - track.height) / 2

                    x: {
                        if (root.profile === 0)
                            return 0

                        if (root.profile === 1)
                            return (track.width - width) / 2

                        return track.width - width
                    }

                    color: root.accentColor

                    border.width: 1
                    border.color: Qt.lighter(root.accentColor, 1.2)

                    Behavior on x {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                        }
                    }

                    Text {
                        anchors.centerIn: parent

                        text: root.icons[root.profile]

                        color: "#11111b"

                        font.pixelSize: 17

                        anchors.horizontalCenterOffset: 1
                        anchors.verticalCenterOffset: -2
                    }
                }
            }

            Row {
                anchors.fill: parent

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            root.profile = 0
                            setProfile.running = true
                        }
                    }
                }

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            root.profile = 1
                            setProfile.running = true
                        }
                    }
                }

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            root.profile = 2
                            setProfile.running = true
                        }
                    }
                }
            }
        }
    }
}
