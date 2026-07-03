import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtMultimedia

Rectangle {
    id: root
    color: "#F5F5F5"

    property int currentPlayingIndex: -1
    property int dragFromIndex: -1
    property int dragToIndex: -1
    property bool isDragging: false

    Timer {
        id: playAfterLoadTimer
        interval: 300
        repeat: false
        property int savedIndex: -1
        onTriggered: {
            mediaPlayer.skipStateReset = true
            mediaPlayer.stop()
            mediaPlayer.play()
            currentPlayingIndex = savedIndex
        }
    }

    MediaPlayer {
        id: mediaPlayer
        audioOutput: AudioOutput {}
        property bool skipStateReset: false
        
        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.StoppedState) {
                if (!skipStateReset) {
                    currentPlayingIndex = -1
                }
                skipStateReset = false
            }
        }
    }

    function formatIndex(idx) {
        var num = idx + 1
        if (num < 10) return "00" + num
        if (num < 100) return "0" + num
        return "" + num
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#FFFFFF"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20

                Text {
                    text: "\u266A \u7535\u53F0\u6B4C\u66F2\u5217\u8868"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#333333"
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "\u5171 " + songModel.count + " \u9996"
                    font.pixelSize: 14
                    color: "#999999"
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#F5F5F5"

            Flickable {
                id: flickable
                anchors.fill: parent
                anchors.margins: 20
                contentWidth: width
                contentHeight: gridContainer.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    width: 8
                    policy: ScrollBar.AsNeeded
                }

                Timer {
                    id: autoScrollTimer
                    interval: 16
                    running: isDragging && (dragToIndex >= 0)
                    repeat: true
                    onTriggered: {
                        var threshold = 60
                        var speed = 0

                        if (flickable.dragMouseY < threshold) {
                            speed = -5 - (threshold - flickable.dragMouseY) * 0.25
                        } else if (flickable.dragMouseY > flickable.height - threshold) {
                            speed = 5 + (flickable.dragMouseY - (flickable.height - threshold)) * 0.25
                        }

                        if (speed !== 0) {
                            var newY = flickable.contentY + speed
                            newY = Math.max(0, Math.min(newY, flickable.contentHeight - flickable.height))
                            flickable.contentY = newY
                        }
                    }
                }

                property real dragMouseY: 0

                Item {
                    id: gridContainer
                    width: flickable.width
                    height: gridLayout.height

                    GridLayout {
                        id: gridLayout
                        width: parent.width
                        columns: 4
                        columnSpacing: 15
                        rowSpacing: 15

                        Repeater {
                            model: ListModel {
                                id: songModel
                            }

                            delegate: songCardDelegate
                        }

                        Rectangle {
                            id: addCard
                            Layout.fillWidth: true
                            Layout.preferredHeight: 260
                            radius: 12
                            color: addCardMouse.containsMouse ? "#E6F7FF" : "#FAFAFA"

                            Canvas {
                                id: dashedBorder
                                anchors.fill: parent
                                property bool isHovered: addCardMouse.containsMouse

                                onIsHoveredChanged: requestPaint()
                                onWidthChanged: requestPaint()
                                onHeightChanged: requestPaint()

                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.clearRect(0, 0, width, height)
                                    ctx.strokeStyle = isHovered ? "#1890FF" : "#D9D9D9"
                                    ctx.lineWidth = 2
                                    ctx.setLineDash([6, 4])
                                    ctx.strokeRect(1, 1, width - 2, height - 2)
                                }
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 10

                                Text {
                                    text: "\uFF0B"
                                    font.pixelSize: 48
                                    color: addCardMouse.containsMouse ? "#1890FF" : "#999999"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: "\u6DFB\u52A0\u6B4C\u66F2"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: addCardMouse.containsMouse ? "#1890FF" : "#666666"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: "(MP3 \u683C\u5F0F)"
                                    font.pixelSize: 12
                                    color: "#999999"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }

                            MouseArea {
                                id: addCardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: fileDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: songCardDelegate

        Rectangle {
            id: cardRoot
            width: 245
            height: 260
            radius: 12
            color: "#FFFFFF"
            border.width: cardMouse.containsMouse ? 1 : 0
            border.color: cardMouse.containsMouse ? "#E8E8E8" : "transparent"

            property bool isPlaying: currentPlayingIndex === index
            property bool isBeingDragged: dragFromIndex === index && isDragging

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.width: isBeingDragged ? 2 : 0
                border.color: "#1890FF"
                opacity: isBeingDragged ? 0.85 : 1.0
                scale: isBeingDragged ? 1.02 : 1.0

                Behavior on opacity { NumberAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 100 } }
            }

            Rectangle {
                id: playingIndicator
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 4
                color: "#52C41A"
                visible: isPlaying
                radius: 2
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 160
                    Layout.alignment: Qt.AlignHCenter
                    radius: 8
                    color: "#F0F0F0"

                    Image {
                        id: coverImage
                        anchors.fill: parent
                        source: model.coverPath ? "file:///" + model.coverPath : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: model.coverPath && status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "\u266B"
                        font.pixelSize: 48
                        color: "#CCCCCC"
                        visible: !coverImage.visible
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: formatIndex(index)
                        font.pixelSize: 13
                        font.family: "Consolas"
                        color: "#1890FF"
                    }

                    Text {
                        text: model.name || model.filePath.replace(/\.mp3$/i, "")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Text {
                    text: model.album || "\u672A\u77E5\u4E13\u8F91"
                    font.pixelSize: 12
                    color: "#999999"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Item { Layout.fillHeight: true }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32

                    RowLayout {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: playMouse.containsMouse ? "#73D13D" : "#52C41A"

                            Text {
                                anchors.centerIn: parent
                                text: isPlaying ? "\u23F8" : "\u25B6"
                                font.pixelSize: 14
                                color: "#FFFFFF"
                            }

MouseArea {
                                 id: playMouse
                                 anchors.fill: parent
                                 hoverEnabled: true
                                 cursorShape: Qt.PointingHandCursor
                                 onClicked: {
                                     if (isPlaying) {
                                         mediaPlayer.stop()
                                         currentPlayingIndex = -1
                                     } else {
                                         var newSource = "file:///" + radioConfig.songsDir() + "/" + model.filePath
                                         if (mediaPlayer.source.toString() === newSource) {
                                             mediaPlayer.play()
                                         } else {
                                             mediaPlayer.source = newSource
                                             mediaPlayer.play()
                                             playAfterLoadTimer.savedIndex = index
                                             playAfterLoadTimer.start()
                                         }
                                         currentPlayingIndex = index
                                     }
                                 }
                             }
                        }

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: deleteMouse.containsMouse ? "#FF4D4F" : "#FF7875"
                            opacity: cardMouse.containsMouse ? 1.0 : 0.0

                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "\u2715"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                id: deleteMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: cardMouse.containsMouse
                                onClicked: {
                                    deleteConfirmDialog.deleteIndex = index
                                    deleteConfirmDialog.open()
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    color: "transparent"

                    Row {
                        anchors.centerIn: parent
                        spacing: 3

                        Repeater {
                            model: 3
                            Rectangle {
                                width: 16
                                height: 2
                                radius: 1
                                color: dragMouse.containsMouse ? "#1890FF" : "#D9D9D9"
                            }
                        }
                    }

                    MouseArea {
                        id: dragMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.ClosedHandCursor

                        onPressed: {
                            dragFromIndex = index
                            isDragging = true
                        }

                        onReleased: {
                            if (dragToIndex >= 0 && dragToIndex !== dragFromIndex) {
                                songModel.move(dragFromIndex, dragToIndex)
                                radioConfig.moveSong(dragFromIndex, dragToIndex)
                                radioConfig.saveConfig()
                            }
                            isDragging = false
                            dragFromIndex = -1
                            dragToIndex = -1
                        }

                        onPositionChanged: {
                            if (isDragging) {
                                var globalPos = mapToItem(root, mouseX, mouseY)
                                flickable.dragMouseY = globalPos.y

                                var gridPos = mapToItem(gridLayout, mouseX, mouseY)
                                var col = Math.floor(gridPos.x / (gridLayout.width / 4))
                                var row = Math.floor(gridPos.y / 275)
                                var targetIdx = row * 4 + col

                                if (targetIdx >= 0 && targetIdx < songModel.count) {
                                    dragToIndex = targetIdx
                                }
                            }
                        }
                    }
                }
            }

            MouseArea {
                id: cardMouse
                anchors.fill: parent
                hoverEnabled: true
                z: -1
            }
        }
    }

    Dialog {
        id: deleteConfirmDialog
        title: "\u786E\u8BA4\u5220\u9664"
        modal: true
        anchors.centerIn: parent

        property int deleteIndex: -1

        ColumnLayout {
            spacing: 10

            Text {
                text: "\u786E\u5B9A\u8981\u5220\u9664\u8FD9\u9996\u6B4C\u66F2\u5417\uFF1F"
                font.pixelSize: 14
                color: "#333333"
            }

            RowLayout {
                spacing: 10

                Button {
                    text: "\u786E\u5B9A"
                    font.pixelSize: 14

                    background: Rectangle {
                        color: parent.hovered ? "#FF4D4F" : "#FF4D4F"
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (deleteConfirmDialog.deleteIndex >= 0) {
                            if (currentPlayingIndex === deleteConfirmDialog.deleteIndex) {
                                mediaPlayer.stop()
                                currentPlayingIndex = -1
                            }
                            songModel.remove(deleteConfirmDialog.deleteIndex)
                            radioConfig.removeSong(deleteConfirmDialog.deleteIndex)
                            radioConfig.saveConfig()
                            deleteConfirmDialog.deleteIndex = -1
                            deleteConfirmDialog.close()
                        }
                    }
                }

                Button {
                    text: "\u53D6\u6D88"
                    font.pixelSize: 14

                    background: Rectangle {
                        color: parent.hovered ? "#E0E0E0" : "#FFFFFF"
                        border.color: "#D9D9D9"
                        border.width: 1
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#333333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        deleteConfirmDialog.deleteIndex = -1
                        deleteConfirmDialog.close()
                    }
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "\u9009\u62E9 MP3 \u6B4C\u66F2"
        nameFilters: ["MP3 \u6587\u4EF6 (*.mp3)"]
        onAccepted: {
            var srcPath = selectedFile.toString()
            if (srcPath.startsWith("file:///")) {
                srcPath = srcPath.substring(8)
            }
            var storedFileName = radioConfig.importSong(srcPath)
            if (storedFileName !== "") {
                var name = storedFileName.replace(/\.mp3$/i, "")
                songModel.append({
                    "name": name,
                    "filePath": storedFileName,
                    "album": "",
                    "coverPath": ""
                })
                radioConfig.addSong(name, storedFileName, "")
                radioConfig.saveConfig()
            }
        }
    }

    Component.onCompleted: {
        songModel.clear()
        var songs = radioConfig.getSongList()
        for (var i = 0; i < songs.length; i++) {
            songModel.append({
                "name": songs[i].name,
                "filePath": songs[i].filePath,
                "album": songs[i].album || "",
                "coverPath": songs[i].coverPath || ""
            })
        }
    }
}
