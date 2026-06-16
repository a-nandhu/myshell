import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Services.UPower

Rectangle {
    id: buttonRoot
    
    width: 120
    height: 36
    color: "#313244"
    radius: 8

    readonly property real batteryCharge: UPower.displayDevice.percentage * 100
    readonly property real batteryHealth: UPower.displayDevice.healthSupported ? (UPower.displayDevice.healthPercentage * 100) : 100

    function getHorizontalBatteryIcon(pct) {
        if (!UPower.onBattery) return "";
        if (pct >= 85) return "";
        if (pct >= 60) return "";
        if (pct >= 35) return "";
        if (pct >= 15) return "";
        return "";
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 6
        Text {
            id: controlCenterIcon
            Layout.alignment: Qt.AlignVCenter
            text: ""
            font.pixelSize: 16
            color: "white"
        }

        Rectangle {
            id: verticalSeparator
            width: 1
            height: 14
            color: "white"
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            width: 28
            height: 28
            Layout.alignment: Qt.AlignVCenter


            Text {
                id: batteryBase
                anchors.centerIn: parent
                text: buttonRoot.getHorizontalBatteryIcon(buttonRoot.batteryCharge)
                color: !UPower.onBattery ? "#a6e3a1" : (batteryCharge > 20 ? "#a6e3a1" : "#f38ba8")
                font.pixelSize: 20
            }

            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -1
                text: "󱐋"
                font.pixelSize: 16
                font.bold: true
                color: "white" 
                visible: !UPower.onBattery
                z: 1
            }
        }

        ColumnLayout {
            spacing: -2
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: Math.round(buttonRoot.batteryCharge) + "%"
                color: "#cdd6f4"
                font.pixelSize: 11
                font.bold: true
            }

        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: controlCenterWindow.visible = !controlCenterWindow.visible
    }

    ControlCenterWindow {
        id: controlCenterWindow
        anchorTarget: buttonRoot
    }

}
