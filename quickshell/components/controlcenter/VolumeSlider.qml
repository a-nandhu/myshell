import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io 

Rectangle {
    id: root
    
    Layout.fillWidth: true
    Layout.columnSpan: 2 
    height: 70
    radius: 10 
    color: "#252538" 

    // --- CONFIGURABLE PROPERTIES ---
    property int value: 50 
    readonly property bool isDragging: dragArea.pressed

    // Strict two-color rule: Red for mute, Blue for all active levels
    readonly property color accentColor: value === 0 ? "#f38ba8" : "#89b4fa"

    // --- PERCEPTUAL AUDIO RANGE MAPPING ---
    readonly property int minAudioThreshold: 14

    function uiToSystem(uiVal) {
        if (uiVal <= 0) return 0;
        return Math.round(minAudioThreshold + (uiVal / 100.0) * (100 - minAudioThreshold));
    }

    function systemToUi(sysVal) {
        if (sysVal <= 0 || sysVal < minAudioThreshold) return 0;
        return Math.round(((sysVal - minAudioThreshold) / (100 - minAudioThreshold)) * 100);
    }

    // =================================================================
    // BACKEND PROCESSES (PIPEWIRE / WPCTL)
    // =================================================================
    Process {
        id: volumeSetter
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "50%"]
        
        property int nextValue: -1
        
        onRunningChanged: {
            if (!running && nextValue !== -1) {
                let mappedVol = root.uiToSystem(nextValue);
                command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", mappedVol + "%"];
                nextValue = -1;
                running = true;
            }
        }
        
        function applyChange(newValue) {
            if (running) {
                nextValue = newValue;
            } else {
                let mappedVol = root.uiToSystem(newValue);
                command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", mappedVol + "%"];
                running = true;
            }
        }
    }

    Process {
        id: volumeFetcher
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let cleanedText = text.trim(); 
                if (cleanedText.startsWith("Volume:")) {
                    let parts = cleanedText.split(":");
                    if (parts.length > 1) {
                        let rawVolume = parts[1].trim().split(" ")[0]; 
                        let volVal = parseFloat(rawVolume);
                        if (!isNaN(volVal) && !root.isDragging) {
                            let systemPercent = Math.round(volVal * 100);
                            root.value = root.systemToUi(systemPercent);
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 1500
        running: !root.isDragging
        repeat: true
        onTriggered: volumeFetcher.running = true 
    }

    // =================================================================
    // MAIN UI LAYOUT ROW
    // =================================================================
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 30
        spacing: 12

        // --- Left Indicator Block (Dynamic changing glyphs stay here) ---
        Rectangle {
            width: 46
            height: 46
            radius: 6
            color: Qt.rgba(
                root.accentColor.r,
                root.accentColor.g,
                root.accentColor.b,
                0.12
            )

            Behavior on color { ColorAnimation { duration: 180 } }

            Item {
                anchors.fill: parent
                scale: root.isDragging ? 0.85 : 1.0

                Behavior on scale {
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }

                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 22 
                    color: root.accentColor
                    
                    text: root.value === 0 ? "󰖁" :
                          root.value < 35  ? "󰕿" :
                          root.value < 70  ? "󰖀" :
                                             "󰕾"

                    Behavior on color { ColorAnimation { duration: 180 } }
                }
            }
        }

        // --- Right Slider Container Component ---
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

                // Active Progress Bar Fill
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    radius: parent.radius
                    width: thumb.x + thumb.width / 2

                    color: Qt.rgba(
                        root.accentColor.r,
                        root.accentColor.g,
                        root.accentColor.b,
                        0.35
                    )

                    Behavior on width {
                        enabled: !root.isDragging
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                    Behavior on color { ColorAnimation { duration: 180 } }
                }

                // Solid Clean 22px Handle (Completely blank inside)
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

                    Behavior on x {
                        enabled: !root.isDragging
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                    Behavior on color { ColorAnimation { duration: 180 } }
                }
            }

            // Interactive Drag Surface Bounds
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
                    volumeSetter.applyChange(newValue);
                }

                onPressed: (mouse) => {
                    dragArea.cursorShape = Qt.ClosedHandCursor;
                    updateValue(mouse);
                }
                onPositionChanged: (mouse) => {
                    if (pressed) {
                        updateValue(mouse);
                    }
                }
                onReleased: {
                    dragArea.cursorShape = Qt.PointingHandCursor;
                }
            }
        }
    }
}
