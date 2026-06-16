import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.columnSpan: 2
    height: 70
    radius: 10
    color: "#252538"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // --- LOCK (Peach) ---
        Rectangle {
            id: lockBtn
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            // Increased resting opacity to 0.18 for a richer dimmed look
            color: mouseLock.containsMouse ? "#fab387" : Qt.rgba(250/255, 179/255, 135/255, 0.18)
            Behavior on color { ColorAnimation { duration: 120 } }
            
            Text { 
                anchors.centerIn: parent
                font.pixelSize: 22
                color: mouseLock.containsMouse ? "#11111b" : "#fab387"
                text: "󰌾"
                Behavior on color { ColorAnimation { duration: 120 } }
            }
            MouseArea { id: mouseLock; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached({ command: ["loginctl", "lock-session"] }) }
        }

        // --- SLEEP (Green) ---
        Rectangle {
            id: sleepBtn
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: mouseSleep.containsMouse ? "#a6e3a1" : Qt.rgba(166/255, 227/255, 161/255, 0.18)
            Behavior on color { ColorAnimation { duration: 120 } }
            
            Text { 
                anchors.centerIn: parent
                font.pixelSize: 22
                color: mouseSleep.containsMouse ? "#11111b" : "#a6e3a1"
                text: "󰤄"
                Behavior on color { ColorAnimation { duration: 120 } }
            }
            MouseArea { id: mouseSleep; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached({ command: ["systemctl", "suspend"] }) }
        }

        // --- RESTART (Blue) ---
        Rectangle {
            id: rebootBtn
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: mouseReboot.containsMouse ? "#89b4fa" : Qt.rgba(137/255, 180/255, 250/255, 0.18)
            Behavior on color { ColorAnimation { duration: 120 } }
            
            Text { 
                anchors.centerIn: parent
                font.pixelSize: 22
                color: mouseReboot.containsMouse ? "#11111b" : "#89b4fa"
                text: "󰜉"
                Behavior on color { ColorAnimation { duration: 120 } }
            }
            MouseArea { id: mouseReboot; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached({ command: ["systemctl", "reboot"] }) }
        }

        // --- SHUTDOWN (Red) ---
        Rectangle {
            id: shutdownBtn
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: mouseShutdown.containsMouse ? "#f38ba8" : Qt.rgba(243/255, 139/255, 168/255, 0.18)
            Behavior on color { ColorAnimation { duration: 120 } }
            
            Text { 
                anchors.centerIn: parent
                font.pixelSize: 22
                color: mouseShutdown.containsMouse ? "#11111b" : "#f38ba8"
                text: "󰐥"
                Behavior on color { ColorAnimation { duration: 120 } }
            }
            MouseArea { id: mouseShutdown; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached({ command: ["systemctl", "poweroff"] }) }
        }
    }
}
