import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: toggleRoot

    Layout.fillWidth: true
    height: 70

    radius: 10
    color: "#252538"

    property string deviceName: "Searching..."

    readonly property bool isEnabled:
        deviceName !== "Disabled"

    readonly property bool isConnected:
        deviceName !== "Disconnected"
        && deviceName !== "Disabled"
        && deviceName !== "Searching..."
        && deviceName !== ""

    readonly property color accentColor:
        isConnected ? "#89b4fa" : "#6c7086"

    Process {
        id: bluetoothFetcher

        command: [
            "sh",
            "-c",
            "if ! bluetoothctl show | grep -q 'Powered: yes'; then echo 'Disabled'; else dev=$(bluetoothctl devices Connected | cut -d' ' -f3-); echo \"${dev:-Disconnected}\"; fi"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let cleanedText = text.trim();

                if (cleanedText.length > 0) {
                    toggleRoot.deviceName = cleanedText;
                } else {
                    toggleRoot.deviceName = "Disconnected";
                }
            }
        }
    }

    Timer {
        interval: 4000
        running: true
        repeat: true

        onTriggered: {
            bluetoothFetcher.running = true;
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        spacing: 12

        // --------------------------------------------------
        // Icon Tile
        // --------------------------------------------------

        Rectangle {
            width: 46
            height: 46

            radius: 6

            color: Qt.rgba(
                toggleRoot.accentColor.r,
                toggleRoot.accentColor.g,
                toggleRoot.accentColor.b,
                0.12
            )

            Text {
                anchors.centerIn: parent

                text:
                    toggleRoot.isEnabled
                    ? "󰂯"
                    : "󰂲"

                color: toggleRoot.accentColor

                font.pixelSize: 20

                anchors.horizontalCenterOffset: 1
                anchors.verticalCenterOffset: -1
            }
        }

        // --------------------------------------------------
        // Text Area
        // --------------------------------------------------

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            spacing: 0

            Text {
                text: toggleRoot.deviceName

                color:
                    toggleRoot.isConnected
                    ? "#cdd6f4"
                    : "#6c7086"

                font.pixelSize: 14
                font.bold: true

                elide: Text.ElideRight

                Layout.fillWidth: true
            }

            Text {
                text:
                    toggleRoot.deviceName === "Disabled"
                    ? "Bluetooth Off"
                    : toggleRoot.isConnected
                        ? "Connected"
                        : "Disconnected"

                color: "#6c7086"

                font.pixelSize: 11

                Layout.fillWidth: true
            }
        }
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            popupRoot.closePopup()
            console.log(
                "Bluetooth Button Pressed. Current Device: "
                + toggleRoot.deviceName
            );
        }
    }
}
