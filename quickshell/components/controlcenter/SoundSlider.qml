import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes          
import Quickshell.Io 

Rectangle {
    id: sliderRoot
    
    Layout.fillWidth: true
    Layout.columnSpan: 2 
    
    height: 70
    radius: 10 
    color: "#252538" 

    // --- CONFIGURABLE PROPERTIES ---
    property int value: 50 
    property int handleMargin: 4
    readonly property bool isDragging: handleArea.pressed

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
    // HIGH-PERFORMANCE PROCESS QUEUE (TARGETING PIPEWIRE / WPCTL)
    // =================================================================
    Process {
        id: volumeSetter
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "50%"]
        
        property int nextValue: -1
        
        onRunningChanged: {
            if (!running && nextValue !== -1) {
                let mappedVol = sliderRoot.uiToSystem(nextValue);
                command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", mappedVol + "%"];
                nextValue = -1;
                running = true;
            }
        }
        
        function applyChange(newValue) {
            if (running) {
                nextValue = newValue;
            } else {
                let mappedVol = sliderRoot.uiToSystem(newValue);
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
                        if (!isNaN(volVal) && !sliderRoot.isDragging) {
                            let systemPercent = Math.round(volVal * 100);
                            sliderRoot.value = sliderRoot.systemToUi(systemPercent);
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 1500
        running: !sliderRoot.isDragging
        repeat: true
        onTriggered: volumeFetcher.running = true 
    }

    // =================================================================
    // MAIN UI LAYOUT ROW
    // =================================================================
    RowLayout {
        anchors.fill: parent
        anchors.margins: 14 
        spacing: 12

        // --- 1. CRISP NATIVE VECTOR AUDIO GLYPH (WITH REACTIVE SCALE) ---
        Item {
            id: audioIconContainer
            width: 24 // Restored back to full original structural width
            height: 24
            Layout.alignment: Qt.AlignVCenter 

            readonly property color iconColor: Qt.rgba(
                0.478 + (sliderRoot.value / 100) * 0.498, 
                0.525 + (sliderRoot.value / 100) * 0.361, 
                0.741 - (sliderRoot.value / 100) * 0.055, 
                1.0
            )

            readonly property real wave1Visible: sliderRoot.value > 0 ? 1.0 : 0.0
            readonly property real wave2Visible: sliderRoot.value > 33 ? 1.0 : 0.0
            readonly property real wave3Visible: sliderRoot.value > 66 ? 1.0 : 0.0

            // INTERACTIVE SCALING INNER WRAPPER: 
            // Shrinks down slightly when dragging, bounces back up to 1.0 when released.
            Item {
                anchors.fill: parent
                scale: sliderRoot.isDragging ? 0.85 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }

                // Static Speaker Backpiece
                Shape {
                    anchors.fill: parent
                    antialiasing: true 

                    ShapePath {
                        fillColor: audioIconContainer.iconColor
                        strokeColor: "transparent"
                        PathSvg { path: "M4,9 H7 L12,4 V20 L7,15 H4 Z" }
                    }
                }

                // Wave 1: Low Range
                Shape {
                    anchors.fill: parent
                    opacity: audioIconContainer.wave1Visible
                    antialiasing: true
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: audioIconContainer.iconColor
                        strokeWidth: 2 
                        capStyle: ShapePath.RoundCap
                        PathSvg { path: "M15,9 A3.5,3.5 0 0,1 15,15" }
                    }
                }

                // Wave 2: Mid Range
                Shape {
                    anchors.fill: parent
                    opacity: audioIconContainer.wave2Visible
                    antialiasing: true
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: audioIconContainer.iconColor
                        strokeWidth: 2
                        capStyle: ShapePath.RoundCap
                        PathSvg { path: "M17.5,6.5 A6.5,6.5 0 0,1 17.5,17.5" }
                    }
                }

                // Wave 3: High Range
                Shape {
                    anchors.fill: parent
                    opacity: audioIconContainer.wave3Visible
                    antialiasing: true
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: audioIconContainer.iconColor
                        strokeWidth: 2
                        capStyle: ShapePath.RoundCap
                        PathSvg { path: "M20,4 A9.5,9.5 0 0,1 20,20" }
                    }
                }
            }
        }

        // --- 2. MAIN SLIDER ELEMENT ---
        Item {
            id: sliderTrack
            Layout.fillWidth: true
            height: 22 
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: "#1e1e2e" 
            }

            Rectangle {
                id: activeFill
                height: parent.height
                radius: height / 2
                color: "#89b4fa" 
                
                anchors.left: parent.left
                anchors.right: handleElement.right
                anchors.rightMargin: -sliderRoot.handleMargin
                
                visible: sliderRoot.value > 0
            }

            Rectangle {
                id: handleElement
                anchors.verticalCenter: parent.verticalCenter
                x: ((sliderTrack.width - width - sliderRoot.handleMargin) * sliderRoot.value) / 100

                width: isDragging ? 18 : 14 
                height: width 
                radius: width / 2
                color: "#cdd6f4" 

                border.color: isDragging ? "#a6e3a1" : "transparent" 
                border.width: isDragging ? 1.5 : 0

                Behavior on width { NumberAnimation { duration: 100 } }

                Behavior on x {
                    enabled: !handleArea.pressed 
                    SpringAnimation {
                        id: releaseSpring
                        spring: 3   
                        damping: 0.25 
                        epsilon: 0.1
                    }
                }
            }

            MouseArea {
                id: handleArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                function updateValueFromMouse(mouse) {
                    let maxTravel = sliderTrack.width - (handleElement.isDragging ? 18 : 14) - sliderRoot.handleMargin;
                    let positionInRange = Math.max(0, Math.min(1.0, mouse.x / maxTravel));
                    let newValue = Math.round(positionInRange * 100);
                    
                    sliderRoot.value = newValue;
                    volumeSetter.applyChange(newValue);
                }

                onPressed: {
                    updateValueFromMouse(mouse);
                    handleArea.cursorShape = Qt.ClosedHandCursor; 
                }
                onPositionChanged: {
                    if (pressed) {
                        updateValueFromMouse(mouse);
                    }
                }
                onReleased: {
                    handleArea.cursorShape = Qt.PointingHandCursor; 
                }
            }
        }

        // --- 4. PERCENTAGE TEXT (HARD LAYOUT LOCKDOWN) ---
        Text {
            id: percentageLabel
            text: sliderRoot.value + "%"
            color: isDragging ? "#89b4fa" : "#585b70" 
            font.pixelSize: 11
            font.bold: isDragging
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            
            Layout.fillWidth: false
            Layout.minimumWidth: 45
            Layout.maximumWidth: 45
            Layout.preferredWidth: 45
            
            Behavior on color { ColorAnimation { duration: 100 } }
        }
    }
}
