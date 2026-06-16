import QtQuick
import Quickshell

Rectangle {
    height: 30
    width: 140
    radius: 3
    color: "red"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "hh:mm AP")
        color: "white"
        font.bold: true
        font.pixelSize: 16
    }
}
