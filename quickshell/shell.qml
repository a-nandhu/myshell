import Quickshell
import QtQuick
import "components/controlcenter"
import Quickshell.Services.Mpris

Scope {

    id: root



    Bar {
        id: topBar
    }

    ControlCenterWindow {
        id: controlCenter
    }
}
