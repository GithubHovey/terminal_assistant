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
                        source: {
                            if (!model.cover || !radioConfig) return ""
                            var coverPath = model.cover
                            if (coverPath.endsWith(".bin")) {
                                coverPath = coverPath.substring(0, coverPath.length - 4) + ".png"
                            }
                            var path = "file:///" + radioConfig.musicDir() + "/" + coverPath
                            return path + "?v=" + radioConfig.coverVersion
                        }
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
                if (importBusyIndicator.running) {
                    importBusyDialog.open()
                }
            }
        }
    }

    Connections {
        target: radioConfig
        function onImportStarted() {
            importBusyIndicator.running = true
            importBusyDialog.open()
        }
        function onImportFinished(id, success) {
            importBusyIndicator.running = false
            importBusyDialog.close()
            if (success && id === pendingImportId) {
                coverFileDialog.open()
            } else if (!success) {
                pendingImportId = ""
                pendingImportTitle = ""
            }
        }
    }

    Dialog {
        id: importBusyDialog
        title: "导入中"
        modal: true
        standardButtons: Dialog.NoButton
        closePolicy: Dialog.NoAutoClose
        anchors.centerIn: parent
        width: 240
        height: 120

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            BusyIndicator {
                id: importBusyIndicator
                running: false
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "正在转换音频..."
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    FileDialog {
        id: coverFileDialog
        title: "选择封面图片 (可跳过)"
        nameFilters: ["图片文件 (*.png *.jpg *.jpeg)"]
        onAccepted: {
            var srcPath = selectedFile.toString()
            // 打开裁剪对话框而不是直接导入
            coverCropDialog.sourceImagePath = srcPath
            coverCropDialog.songId = pendingImportId
            coverCropDialog.open()
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
        id: coverCropDialog
        title: "调整封面"
        modal: true
        anchors.centerIn: parent
        width: 320
        height: 420
        
        property string sourceImagePath: ""
        property string songId: ""  // e.g., "001"
        property real scaleValue: 1.0
        property real offsetX: 0
        property real offsetY: 0
        
        onOpened: {
            console.log("coverCropDialog opened with source:", sourceImagePath, "songId:", songId)
            scaleValue = 1.0
            offsetX = 0
            offsetY = 0
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 15
            
            // 方形预览区域 (200x200)
            Item {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200
                Layout.alignment: Qt.AlignHCenter
                
                Rectangle {
                    anchors.fill: parent
                    color: "#F0F0F0"
                    border.color: "#D9D9D9"
                    border.width: 1
                }
                
                Rectangle {
                    id: coverClipMask
                    anchors.fill: parent
                    color: "transparent"
                    clip: true
                    
                    Image {
                        id: coverCropImage
                        width: parent.width
                        height: parent.height
                        source: coverCropDialog.sourceImagePath
                        fillMode: Image.PreserveAspectCrop
                        scale: coverCropDialog.scaleValue
                        x: (parent.width - width) / 2 + coverCropDialog.offsetX
                        y: (parent.height - height) / 2 + coverCropDialog.offsetY
                        
                        onStatusChanged: {
                            if (status === Image.Ready) {
                                console.log("Cover image loaded:", source, "size:", sourceSize)
                            } else if (status === Image.Error) {
                                console.log("Cover image load error:", source)
                            }
                        }
                    }
                }
                
                // 方形边框（上层）
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "#1890FF"
                    border.width: 2
                }
                
                // 拖拽交互层（最上层）
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.OpenHandCursor
                    property point lastPos
                    property bool dragging: false
                    
                    onPressed: {
                        console.log("MouseArea pressed at:", mouseX, mouseY)
                        dragging = true
                        lastPos = Qt.point(mouseX, mouseY)
                        cursorShape = Qt.ClosedHandCursor
                    }
                    
                    onPositionChanged: {
                        if (dragging) {
                            var dx = mouseX - lastPos.x
                            var dy = mouseY - lastPos.y
                            console.log("Dragging: dx=", dx, "dy=", dy, "old offset=", coverCropDialog.offsetX, coverCropDialog.offsetY)
                            coverCropDialog.offsetX += dx
                            coverCropDialog.offsetY += dy
                            lastPos = Qt.point(mouseX, mouseY)
                            console.log("New offset:", coverCropDialog.offsetX, coverCropDialog.offsetY)
                        }
                    }
                    
                    onReleased: {
                        console.log("MouseArea released")
                        dragging = false
                        cursorShape = Qt.OpenHandCursor
                    }
                }
            }
            
            // 缩放滑块
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: "缩放:"
                    font.pixelSize: 12
                    color: "#666666"
                }
                
                Slider {
                    id: coverScaleSlider
                    Layout.fillWidth: true
                    from: 0.5
                    to: 3.0
                    value: 1.0
                    stepSize: 0.1
                    
                    onValueChanged: {
                        coverCropDialog.scaleValue = value
                        console.log("Scale changed to:", value)
                    }
                }
                
                Text {
                    text: coverScaleSlider.value.toFixed(1)
                    font.pixelSize: 12
                    color: "#666666"
                    Layout.preferredWidth: 30
                }
            }
            
            // 提示文字
            Text {
                text: "拖拽移动图片，滑块调整缩放"
                font.pixelSize: 11
                color: "#999999"
                Layout.alignment: Qt.AlignHCenter
            }
            
            // 按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "确定"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                    
                    background: Rectangle {
                        color: parent.hovered ? "#40A9FF" : "#1890FF"
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
                        console.log("确定按钮被点击")
                        
                        try {
                            var songId = coverCropDialog.songId
                            
                            if (songId === "") {
                                logger.logWarning("歌曲ID为空")
                                return
                            }
                            
                            if (coverCropDialog.sourceImagePath === "") {
                                logger.logWarning("未选择封面图片")
                                return
                            }
                            
                            // 转换 URL 为本地路径
                            var inputPath = coverCropDialog.sourceImagePath
                            console.log("原始路径:", inputPath)
                            
                            // 移除 file:/// 前缀
                            if (inputPath.startsWith("file:///")) {
                                inputPath = inputPath.substring(8)
                            } else if (inputPath.startsWith("file://")) {
                                inputPath = inputPath.substring(7)
                            }
                            
                            // Windows 路径处理：/D:/... -> D:/...
                            if (inputPath.length > 2 && inputPath.charAt(0) === "/" && inputPath.charAt(2) === ":") {
                                inputPath = inputPath.substring(1)
                            }
                            
                            console.log("转换后路径:", inputPath)
                            
                            // 计算输出路径
                            var songDir = radioConfig.songDir(songId)
                            var pngPath = songDir + "/cover.png"
                            var binPath = songDir + "/cover.bin"
                            
                            console.log("songDir:", songDir)
                            console.log("pngPath:", pngPath)
                            console.log("binPath:", binPath)
                            console.log("offsetX:", coverCropDialog.offsetX, "offsetY:", coverCropDialog.offsetY)
                            console.log("scaleValue:", coverCropDialog.scaleValue)
                            logger.logInfo("开始处理封面: " + pngPath)
                            
                            // 确保歌曲目录存在
                            radioConfig.ensureSongDir(songId)
                            
                            // 验证 imageProcessor 是否存在
                            if (typeof imageProcessor === "undefined" || !imageProcessor) {
                                logger.logError("imageProcessor 未注册")
                                return
                            }
                            
                            if (typeof imageProcessor.cropRectangular !== "function") {
                                logger.logError("cropRectangular 函数不存在")
                                return
                            }
                            
                            // 调用 C++ 裁剪生成 PNG
                            var success = imageProcessor.cropRectangular(
                                inputPath,
                                pngPath,
                                160,  // targetWidth
                                160,  // targetHeight
                                coverCropDialog.offsetX,
                                coverCropDialog.offsetY,
                                coverCropDialog.scaleValue,
                                200,  // previewWidth
                                200   // previewHeight
                            )
                            
                            console.log("cropRectangular 返回:", success)
                            
                            if (success) {
                                logger.logInfo("PNG裁剪成功，开始转换为BIN...")
                                
                                // 验证 pythonRunner 是否存在
                                if (typeof pythonRunner === "undefined" || !pythonRunner) {
                                    logger.logError("pythonRunner 未注册")
                                    return
                                }
                                
                                // 调用 Python 转换为 BIN
                                var binSuccess = pythonRunner.runScript("convert_image", [
                                    "--type", "cover",
                                    "--input", pngPath,
                                    "--output", binPath
                                ])
                                
                                console.log("runScript 返回:", binSuccess)
                                
                                if (binSuccess) {
                                    logger.logInfo("封面处理完成: " + binPath)
                                    var coverPath = songId + "/cover.bin"
                                    // 更新模型中的数据
                                    for (var i = 0; i < songModel.count; i++) {
                                        if (songModel.get(i).id === songId) {
                                            songModel.setProperty(i, "cover", coverPath)
                                            radioConfig.updateSongCover(i, coverPath)
                                            break
                                        }
                                    }
                                    radioConfig.incrementCoverVersion()
                                    radioConfig.saveConfig()
                                    coverCropDialog.close()
                                } else {
                                    logger.logError("BIN转换失败: " + pythonRunner.getOutput())
                                }
                            } else {
                                logger.logError("PNG裁剪失败")
                            }
                        } catch (e) {
                            console.error("封面处理错误:", e)
                            logger.logError("处理失败: " + e.toString())
                        }
                    }
                }
                
                Button {
                    text: "取消"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                    
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
                        coverCropDialog.close()
                    }
                }
            }
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
                    source: {
                        if (!coverChangeDialog.coverPath || !radioConfig) return ""
                        var coverPath = coverChangeDialog.coverPath
                        if (coverPath.endsWith(".bin")) {
                            coverPath = coverPath.substring(0, coverPath.length - 4) + ".png"
                        }
                        var path = "file:///" + radioConfig.musicDir() + "/" + coverPath
                        return path + "?v=" + radioConfig.coverVersion
                    }
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
                    source: {
                        if (!coverChangeDialog.coverPath || !radioConfig) return ""
                        var coverPath = coverChangeDialog.coverPath
                        if (coverPath.endsWith(".bin")) {
                            coverPath = coverPath.substring(0, coverPath.length - 4) + ".png"
                        }
                        var path = "file:///" + radioConfig.musicDir() + "/" + coverPath
                        return path + "?v=" + radioConfig.coverVersion
                    }
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
        title: "选择封面图片"
        nameFilters: ["图片文件 (*.png *.jpg *.jpeg)"]
        property int songIndex: -1
        onAccepted: {
            var srcPath = selectedFile.toString()
            // 获取歌曲ID
            var songId = songModel.get(songIndex).id
            // 打开裁剪对话框
            coverCropDialog.sourceImagePath = srcPath
            coverCropDialog.songId = songId
            coverCropDialog.open()
        }
    }

    Component.onCompleted: {
        syncModelFromBackend()
    }
}
