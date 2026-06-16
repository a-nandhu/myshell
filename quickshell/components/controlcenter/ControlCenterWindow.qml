import Quickshell
import QtQuick
import QtQuick.Layouts

PopupWindow {
    id: popupRoot
    visible: false // Controlled strictly by the status bar button
    grabFocus: true
    
    implicitWidth: 600  // The golden standard width for clean, scannable desktop dropdowns
    implicitHeight: 700 // Tall enough to fit toggles, sliders, and media without crowding
    color: "transparent" // Removes rigid system window corners



    function closePopup() {
        popupRoot.visible = false
    }

    // --- POSITIONING BRIDGE ---
    property alias anchorTarget: popupAnchor.item

    anchor {
        id: popupAnchor
        edges: Edges.Bottom | Edges.Right
        gravity: Edges.Bottom | Edges.Left
        margins.top: 8 // Clean gap between the top bar and the window frame
    }

    // Main Visual Background Panel Canvas
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e" // Deep charcoal/navy base
        radius: 16       // Smooth premium rounded corners
        border.color: "#313244" // Subtle border line that stands out against wallpaper
        border.width: 1
        antialiasing: true
        clip: true // Guarantees child elements never leak past the rounded corners

        // Master Vertical Content Column
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20 // Clean padding around all edges
            spacing: 16         // Perfectly uniform spacing between UI modules

            // =============================================================
            // 1. TOP HEADER ROW (Title & System Status Indicators)
            // =============================================================
            RowLayout {
                Layout.fillWidth: true
            }

            GridLayout {
                id: mainButtonGrid
                Layout.fillWidth: true
                columns: 2       // Forces elements to sit side-by-side in pairs
                rowSpacing: 12   // Vertical space between tile rows
                columnSpacing: 12 // Horizontal space between side-by-side tiles

                Wifi {

                    onClicked: {
                        popupRoot.closePopup()
                    }
                }

                Bluetooth {}

                Audio {}

                Microphone {}

                PowerProfile {}

                VPNButton {}

                BrightnessSlider {}

                VolumeSlider {}

                MediaControl {}

                PowerMenu {}

            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
