import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io 

Rectangle {
    id: root
    
    // --- INITIALIZATION FIX ---
    // Instead of calling a function, we trigger a dedicated Process object
    Component.onCompleted: {
        initializer.running = true
    }

    Process {
        id: initializer
        command: ["brightnessctl", "-d", "amdgpu_bl2", "get", "-P"]
        stdout: StdioCollector {
            onStreamFinished: {
                let val = parseInt(text.trim());
                if (!isNaN(val)) root.value = val;
            }
        }
    }
    // --------------------------

    Layout.fillWidth: true
    Layout.columnSpan: 2 
    height: 70
    radius: 10 
    color: "#252538" 

    property int value: 50 
    readonly property bool isDragging: dragArea.pressed

    readonly property color accentColor: {
        if (value >= 25) {
            return "#89b4fa";
        } else {
            let t = value / 25.0; 
            return Qt.rgba(
                (108 + t * (137 - 108)) / 255.0,
                (112 + t * (180 - 112)) / 255.0,
                (134 + t * (250 - 134)) / 255.0,
                1.0
            );
        }
    }

    Process {
        id: brightnessSetter
        command: ["brightnessctl", "-d", "amdgpu_bl2", "set", "50%"]
        property int nextValue: -1
        onRunningChanged: {
            if (!running && nextValue !== -1) {
                command = ["brightnessctl", "-d", "amdgpu_bl2", "set", nextValue + "%"];
                nextValue = -1;
                running = true;
            }
        }
        function applyChange(newValue) {
            if (running) { nextValue = newValue; } 
            else { command = ["brightnessctl", "-d", "amdgpu_bl2", "set", newValue + "%"]; running = true; }
        }
    }

    Process {
        id: brightnessFetcher
        command: ["brightnessctl", "-d", "amdgpu_bl2", "get", "-P"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let cleanedText = text.trim();
                if (cleanedText.length > 0 && !root.isDragging) {
                    root.value = parseInt(cleanedText);
                }
            }
        }
    }

    Timer {
        interval: 1500
        running: !root.isDragging
        repeat: true
        onTriggered: brightnessFetcher.running = true 
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 30
        spacing: 12

        Rectangle {
            width: 46
            height: 46
            radius: 6
            color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.12)
            Behavior on color { ColorAnimation { duration: 80 } }

            Item {
                id: sunIconContainer
                width: 24
                height: 24
                anchors.centerIn: parent
                rotation: root.value * 0.9
                scale: root.isDragging ? 0.85 : 1.0
                readonly property color iconColor: root.accentColor
                readonly property real morphProgress: Math.max(0.0, Math.min(1.0, root.value / 30.0))
                readonly property real rayProgress: Math.max(0.0, Math.min(1.0, (root.value - 20) / 80.0))

                Behavior on rotation { enabled: !root.isDragging; NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                Rectangle {
                    id: celestialCore
                    anchors.centerIn: parent
                    width: 11
                    height: width
                    radius: width / 2
                    color: sunIconContainer.iconColor
                    Rectangle {
                        width: parent.width
                        height: parent.height
                        radius: width / 2
                        color: "#252538" 
                        x: 2.5 + (sunIconContainer.morphProgress * 8.0)
                        y: -1.5 - (sunIconContainer.morphProgress * 4.0)
                        opacity: 1.0 - sunIconContainer.morphProgress
                    }
                }

                Repeater {
                    model: 8 
                    Item {
                        anchors.centerIn: parent
                        rotation: index * 45 
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: -(celestialCore.width / 2 + 2.5) - height 
                            width: 2
                            height: sunIconContainer.rayProgress * 3.0
                            radius: 1.5
                            color: sunIconContainer.iconColor
                            opacity: sunIconContainer.rayProgress
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                height: 6
                radius: 3
                color: "#313244"

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    radius: parent.radius
                    width: thumb.x + thumb.width / 2
                    color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.35)
                    Behavior on width { enabled: !root.isDragging; NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 80 } }
                }

                Rectangle {
                    id: thumb
                    width: 22
                    height: 22
                    radius: 11
                    y: -(height - track.height) / 2
                    x: ((track.width - width) * root.value) / 100
                    color: root.accentColor
                    border.width: 1
                    border.color: Qt.lighter(root.accentColor, 1.2)
                    Behavior on x { enabled: !root.isDragging; NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 80 } }
                }
            }

            MouseArea {
                id: dragArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                function updateValue(mouse) {
                    let availableWidth = track.width - thumb.width;
                    if (availableWidth <= 0) return;
                    let targetX = mouse.x - (thumb.width / 2);
                    let boundedX = Math.max(0, Math.min(targetX, availableWidth));
                    let newValue = Math.round((boundedX / availableWidth) * 100);
                    root.value = newValue;
                    brightnessSetter.applyChange(newValue);
                }
                onPressed: (mouse) => { dragArea.cursorShape = Qt.ClosedHandCursor; updateValue(mouse); }
                onPositionChanged: (mouse) => { if (pressed) updateValue(mouse); }
                onReleased: { dragArea.cursorShape = Qt.PointingHandCursor; }
            }
        }
    }
}
