import Quickshell
import QtQuick
import "components"
import "components/controlcenter"

PanelWindow {


    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 10
        left: 10
        right: 10
    }
    implicitHeight: 40
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Workspace {
            
        }

        Clock {
            anchors.centerIn: parent
        }

        ControlCenterButton {
        
            anchors.right: parent.right

        }
        // ControlCenterWindow {
        //     id: ccWindow
        //     visible: false
        // }

    }

}
