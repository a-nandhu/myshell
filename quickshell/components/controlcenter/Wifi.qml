import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: toggleRoot

    signal clicked()


    Layout.fillWidth: true
    height: 70

    radius: 10
    color: "#252538"

    property string ssidName: "Searching..."

    readonly property bool isEnabled:
        ssidName !== "Disabled"

    readonly property bool isConnected:
        ssidName !== "Disconnected"
        && ssidName !== "Searching..."
        && ssidName !== ""

    readonly property color accentColor:
        isConnected ? "#89b4fa" : "#6c7086"

    Process {
        id: wifiFetcher

        command: [
            "sh",
            "-c",
            "nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes:' | cut -d: -f2"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let cleanedText = text.trim();

                if (cleanedText.length > 0) {
                    toggleRoot.ssidName = cleanedText;
                } else {
                    toggleRoot.ssidName = "Disconnected";
                }
            }
        }
    }

    Timer {
        interval: 4000
        running: true
        repeat: true

        onTriggered: {
            wifiFetcher.running = true;
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
                    toggleRoot.isConnected
                    ? "󰤨"
                    : "󰤭"

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
                text: toggleRoot.ssidName

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
                    toggleRoot.isConnected
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

        hoverEnabled: true
        onClicked: {
            popupRoot.closePopup()
            Quickshell.execDetached({
                command: ["kitty", "--class=kitty-popup", "wlctl"]
            })
            console.log(
                "Wi-Fi Button Pressed. Current Network: "
                + toggleRoot.ssidName
            );
        }
    }
}
