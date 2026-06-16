import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    id: workspaceIndicator
    spacing: 3
    height: 30
    Repeater {
        model: 9


        Rectangle {
            property int wsId: index + 1
            property var wsObj: Hyprland.workspaces.values.find(w => w.id === wsId)
            property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
            property bool isOccupied: wsObj !== undefined && !isActive

            visible: wsId <= 5 || wsObj !== undefined

            width: isActive ? 30 : 30
            height: 30
            radius: 3
            anchors.verticalCenter: parent.verticalCenter
            
            color: "transparent"

            Rectangle {
                anchors.centerIn: parent
                width: 12
                height: 12
                radius: 3
                color: "white"
                visible: isActive
            }
            Text {
                anchors.centerIn: parent

                text: wsId
                font.bold: false
                font.pixelSize: 16
                visible: !isActive
                color: isOccupied ? "white" : "#666666"

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

            }
        }
    }
}
