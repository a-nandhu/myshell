import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.columnSpan: 2
    height: 145
    radius: 12
    color: "#252538"

    property var activePlayer: null
    property string cachedArtwork: ""
    property string cachedTitle: ""
    property string cachedArtist: ""

    readonly property bool isPlaying:
        activePlayer &&
        activePlayer.playbackState === MprisPlaybackState.Playing

    readonly property color accentColor:
        isPlaying ? "#89b4fa" : "#a6adc8"

    function updatePlayer() {
        activePlayer = null
        const players = Mpris.players.values
        if (!players || players.length === 0) return

        for (let p of players) {
            if (p && p.playbackState === MprisPlaybackState.Playing && p.trackTitle) {
                activePlayer = p
                return
            }
        }
        for (let p of players) {
            if (p && p.trackTitle) {
                activePlayer = p
                return
            }
        }
        activePlayer = players[0]
    }

    function togglePlayback() {
        if (!activePlayer) return
        try {
            if (activePlayer.canTogglePlaying) activePlayer.togglePlaying()
            else if (isPlaying) activePlayer.pause()
            else activePlayer.play()
        } catch (e) { console.log("Playback error:", e) }
    }

    function getArtwork() { return cachedArtwork }
    
    function progress() {
        const pos = activePlayer ? (activePlayer.position || 0) : 0
        const len = activePlayer ? (activePlayer.length || 0) : 0
        if (len <= 0 || pos < 0 || pos > len) return 0
        return pos / len
    }

    Component.onCompleted: updatePlayer()

    Connections {
        target: Mpris.players
        function onObjectInsertedPost() { updatePlayer() }
        function onObjectRemovedPost() { updatePlayer() }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            updatePlayer()
            if (!activePlayer) return
            cachedTitle = activePlayer.trackTitle || ""
            cachedArtist = activePlayer.trackArtist || ""
            cachedArtwork = activePlayer.trackArtUrl || ""
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // --- ARTWORK ---
        ClippingRectangle {
            Layout.preferredWidth: 112
            Layout.preferredHeight: 112
            radius: 8
            clip: true
            color: "#313244"

            Image {
                anchors.fill: parent
                source: root.getArtwork()
                fillMode: Image.PreserveAspectCrop
                smooth: true
            }
        }

        // --- CONTENT ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.activePlayer ? root.activePlayer.trackTitle : "No media playing"
                color: "#cdd6f4"
                font.pixelSize: 15
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.activePlayer ? (root.activePlayer.trackArtist || root.activePlayer.identity || "Unknown") : "Waiting for media..."
                color: "#a6adc8"
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            // --- PROGRESS & CONTROLS ---
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 16

                Rectangle {
                    id: track
                    Layout.fillWidth: true
                    height: 4
                    radius: 2
                    color: "#313244"

                    Rectangle {
                        height: parent.height
                        radius: parent.radius
                        width: parent.width * root.progress()
                        color: root.accentColor
                        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 16
                    color: "#313244"

                    Text {
                        anchors.centerIn: parent
                        text: root.isPlaying ? "󰏤" : "󰐊"
                        color: root.accentColor
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.togglePlayback()
                    }
                }
            }
        }
    }
}
