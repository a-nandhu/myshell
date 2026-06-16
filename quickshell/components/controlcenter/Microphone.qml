import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: toggleRoot

    Layout.fillWidth: true
    height: 70

    radius: 10
    color: "#252538"

    property string deviceName: "Searching..."
    property bool isMuted: true

    readonly property color accentColor:
        !isMuted ? "#89b4fa" : "#6c7086"

    Process {
        id: micFetcher

        command: [
            "sh",
            "-c",
            "desc=$(pactl list sources | grep -A 15 \"$(pactl get-default-source)\" | grep \"Description:\" | cut -d':' -f2- | xargs); mute=$(pactl get-source-mute $(pactl get-default-source) 2>/dev/null); echo \"$mute|$desc\""
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let cleanedText = text.trim();

                if (cleanedText.length > 0 && cleanedText.includes("|")) {
                    let parts = cleanedText.split("|");

                    toggleRoot.isMuted =
                        parts[0].includes("yes");

                    toggleRoot.deviceName =
                        parts[1]
                        ? parts[1].trim()
                        : "Unknown Input";
                } else {
                    toggleRoot.deviceName = "Disconnected";
                }
            }
        }
    }

    Process {
        id: micToggler

        command: [
            "sh",
            "-c",
            "pactl set-source-mute $(pactl get-default-source) toggle"
        ]

        running: false

        onRunningChanged: {
            if (!running)
                micFetcher.running = true;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: {
            micFetcher.running = true;
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
                    toggleRoot.isMuted
                    ? "󰍭"
                    : "󰍬"

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
                text: "Microphone"

                color: "#cdd6f4"

                font.pixelSize: 14
                font.bold: true

                Layout.fillWidth: true
            }

            Text {
                text:
                    toggleRoot.isMuted
                    ? "Muted"
                    : toggleRoot.deviceName

                color:
                    !toggleRoot.isMuted
                    ? "#a6adc8"
                    : "#6c7086"

                font.pixelSize: 11

                elide: Text.ElideRight

                Layout.fillWidth: true
            }
        }
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            toggleRoot.isMuted = !toggleRoot.isMuted;
            micToggler.running = true;
        }
    }
}
