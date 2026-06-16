import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io 

Rectangle {
    id: root
    
    Layout.fillWidth: true
    Layout.columnSpan: 1  // Single column companion tile format
    height: 70
    radius: 10 
    
    // Track connection state
    property bool isConnected: false

    // Greyed out theme color when disconnected, solid master blue when active
    readonly property color accentColor: isConnected ? "#89b4fa" : "#6c7086"

    // Background highlight behavior
    color: clickArea.containsMouse ? "#2d2d44" : "#252538" 
    Behavior on color { ColorAnimation { duration: 120 } }

    // =================================================================
    // BACKEND PROCESSES (LAUNCHER & AUTOMATIC STATUS TRACKER)
    // =================================================================
    Process {
        id: vpnLauncher
        command: ["protonvpn-app"]
    }

    Process {
        id: statusFetcher
        // Checks NetworkManager active states and falls back to network interfaces
        command: ["sh", "-c", "nmcli con --active | grep -qi proton && echo 1 || (ip link show | grep -qi proton && echo 1 || echo 0)"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let result = text.trim();
                root.isConnected = (result === "1");
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: statusFetcher.running = true 
    }

    // =================================================================
    // COMPACT LAYOUT ROW
    // =================================================================
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        // --- Left Identity Block (46x46 Box) ---
        Rectangle {
            width: 46
            height: 46
            radius: 6
            color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.12)
            Behavior on color { ColorAnimation { duration: 180 } }

            Item {
                anchors.fill: parent
                scale: clickArea.pressed ? 0.90 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 22
                    color: root.accentColor
                    text: "󰌆" 
                    
                    Behavior on color { ColorAnimation { duration: 180 } }
                }
            }
        }

        // --- Clean Compact Label ---
        Text {
            text: "VPN"
            color: root.isConnected ? "#cdd6f4" : "#6c7086" // Text beautifully greys out when offline
            font.pixelSize: 15
            font.bold: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            
            Behavior on color { ColorAnimation { duration: 180 } }
        }
    }

    // =================================================================
    // INTERACTION INTERFACE
    // =================================================================
    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            vpnLauncher.running = true;
        }
    }
}
