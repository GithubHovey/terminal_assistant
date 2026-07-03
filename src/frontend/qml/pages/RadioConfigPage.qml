import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtMultimedia

Rectangle {
    id: root
    color: "#F5F5F5"

    property int currentPlayingIndex: -1
    property string pendingImportId: ""
    property string pendingImportTitle: ""

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

    function moveSongUp(idx) {
        if (idx <= 0) return
        var wasPlaying = currentPlayingIndex
        if (currentPlayingIndex === idx) {
            currentPlayingIndex = idx - 1
        } else if (currentPlayingIndex === idx - 1) {
            currentPlayingIndex = idx
        }
        songModel.move(idx, idx - 1, 1)
        radioConfig.moveSong(idx, idx - 1)
        radioConfig.saveConfig()
        syncModelFromBackend()
        if (wasPlaying >= 0) {
            mediaPlayer.source = "file:///" + radioConfig.musicDir() + "/" + songModel.get(currentPlayingIndex).mp3
        }
    }

    function moveSongDown(idx) {
        if (idx >= songModel.count - 1) return
        var wasPlaying = currentPlayingIndex
        if (currentPlayingIndex === idx) {
            currentPlayingIndex = idx + 1
        } else if (currentPlayingIndex === idx + 1) {
            currentPlayingIndex = idx
        }
        songModel.move(idx, idx + 1, 1)
        radioConfig.moveSong(idx, idx + 1)
        radioConfig.saveConfig()
        syncModelFromBackend()
        if (wasPlaying >= 0) {
            mediaPlayer.source = "file:///" + radioConfig.musicDir() + "/" + songModel.get(currentPlayingIndex).mp3
        }
    }

    function syncModelFromBackend() {
        songModel.clear()
        var songs = radioConfig.getSongList()
        for (var i = 0; i < songs.length; i++) {
            songModel.append({
                "id": songs[i].id,
                "title": songs[i].title,
                "mp3": songs[i].mp3,
                "cover": songs[i].cover || ""
            })
        }
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
                        source: model.cover ? "file:///" + radioConfig.musicDir() + "/" + model.cover : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: model.cover && status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "\u266B"
                        font.pixelSize: 48
                        color: "#CCCCCC"
                        visible: !coverImage.visible
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            coverChangeDialog.songIndex = index
                            coverChangeDialog.coverPath = model.cover
                            coverChangeDialog.open()
                        }
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
                        text: model.title
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
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
                                          var newSource = "file:///" + radioConfig.musicDir() + "/" + model.mp3
                                          radioConfig.configError("播放路径: " + newSource)
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

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Rectangle {
                            width: 28
                            height: 24
                            radius: 4
                            color: upMouse.containsMouse ? "#E6F7FF" : "#F0F0F0"
                            visible: index > 0

                            Text {
                                anchors.centerIn: parent
                                text: "\u2191"
                                font.pixelSize: 14
                                font.bold: true
                                color: upMouse.containsMouse ? "#1890FF" : "#999999"
                            }

                            MouseArea {
                                id: upMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: moveSongUp(index)
                            }
                        }

                        Rectangle {
                            width: 28
                            height: 24
                            radius: 4
                            color: downMouse.containsMouse ? "#E6F7FF" : "#F0F0F0"
                            visible: index < songModel.count - 1

                            Text {
                                anchors.centerIn: parent
                                text: "\u2193"
                                font.pixelSize: 14
                                font.bold: true
                                color: downMouse.containsMouse ? "#1890FF" : "#999999"
                            }

                            MouseArea {
                                id: downMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: moveSongDown(index)
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
                            mediaPlayer.stop()
                            mediaPlayer.source = ""
                            currentPlayingIndex = -1
                            radioConfig.removeSong(deleteConfirmDialog.deleteIndex)
                            radioConfig.saveConfig()
                            syncModelFromBackend()
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
            var lastSlash = srcPath.lastIndexOf("/")
            var fileName = srcPath.substring(lastSlash + 1)
            pendingImportTitle = fileName.replace(/\.mp3$/i, "")
            var importedId = radioConfig.importSong(srcPath)
            if (importedId !== "") {
                pendingImportId = importedId
                coverFileDialog.open()
            }
        }
    }

    FileDialog {
        id: coverFileDialog
        title: "\u9009\u62E9\u5C01\u9762\u56FE\u7247 (\u53EF\u8DF3\u8FC7)"
        nameFilters: ["\u56FE\u7247\u6587\u4EF6 (*.jpg *.jpeg *.png *.bmp *.bin)"]
        onAccepted: {
            var srcPath = selectedFile.toString()
            if (srcPath.startsWith("file:///")) {
                srcPath = srcPath.substring(8)
            }
            var storedCoverPath = radioConfig.importCover(srcPath, pendingImportId)
            finishImport(storedCoverPath)
        }
        onRejected: {
            finishImport("")
        }

        function finishImport(coverPath) {
            songModel.append({
                "id": pendingImportId,
                "title": pendingImportTitle,
                "mp3": pendingImportId + "/" + pendingImportId + ".mp3",
                "cover": coverPath
            })
            radioConfig.addSong(pendingImportId, pendingImportTitle, pendingImportId + "/" + pendingImportId + ".mp3", coverPath)
            radioConfig.saveConfig()
            pendingImportId = ""
            pendingImportTitle = ""
        }
    }

    Dialog {
        id: coverChangeDialog
        title: "\u5C01\u9762\u8BBE\u7F6E"
        modal: true
        anchors.centerIn: parent
        property int songIndex: -1
        property string coverPath: ""

        ColumnLayout {
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 120
                Layout.preferredHeight: 120
                radius: 8
                color: "#F0F0F0"
                clip: true

                Image {
                    anchors.fill: parent
                    source: coverChangeDialog.coverPath ? "file:///" + radioConfig.musicDir() + "/" + coverChangeDialog.coverPath : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: coverChangeDialog.coverPath && status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text: "\u65E0\u5C01\u9762"
                    font.pixelSize: 14
                    color: "#999999"
                    visible: !coverChangeDialog.coverPath || coverImage2.status !== Image.Ready
                }

                Image {
                    id: coverImage2
                    anchors.fill: parent
                    source: coverChangeDialog.coverPath ? "file:///" + radioConfig.musicDir() + "/" + coverChangeDialog.coverPath : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                }
            }

            RowLayout {
                spacing: 10

                Button {
                    text: "\u66F4\u6362\u5C01\u9762"
                    font.pixelSize: 13
                    background: Rectangle {
                        color: parent.hovered ? "#40A9FF" : "#1890FF"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: {
                        coverChangeFileDialog.songIndex = coverChangeDialog.songIndex
                        coverChangeDialog.close()
                        coverChangeFileDialog.open()
                    }
                }

                Button {
                    text: "\u5173\u95ED"
                    font.pixelSize: 13
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
                    }
                    onClicked: coverChangeDialog.close()
                }
            }
        }
    }

    FileDialog {
        id: coverChangeFileDialog
        title: "\u9009\u62E9\u5C01\u9762\u56FE\u7247"
        nameFilters: ["\u56FE\u7247\u6587\u4EF6 (*.jpg *.jpeg *.png *.bmp *.bin)"]
        property int songIndex: -1
        onAccepted: {
            var srcPath = selectedFile.toString()
            if (srcPath.startsWith("file:///")) {
                srcPath = srcPath.substring(8)
            }
            var songs = radioConfig.getSongList()
            var subDir = songs[songIndex].mp3.substring(0, songs[songIndex].mp3.indexOf("/"))
            var storedCoverPath = radioConfig.importCover(srcPath, subDir)
            if (storedCoverPath !== "") {
                songModel.setProperty(songIndex, "cover", storedCoverPath)
                radioConfig.updateSongCover(songIndex, storedCoverPath)
                radioConfig.saveConfig()
            }
        }
    }

    Component.onCompleted: {
        syncModelFromBackend()
    }
}
