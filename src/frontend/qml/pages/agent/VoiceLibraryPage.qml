import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtMultimedia

Rectangle {
    id: root
    color: "#FFFFFF"
    
    property int currentVoiceIndex: -1
    property bool isCreatingNew: false
    property var characterOptions: voiceLibrary ? voiceLibrary.getCharacterOptions() : []
    property string pendingDeleteCloudVoiceId: ""
    
    MediaPlayer {
        id: previewPlayer
        audioOutput: AudioOutput {}
    }
    
    FileDialog {
        id: voiceMaterialFileDialog
        title: "上传声音素材"
        nameFilters: ["音频文件 (*.wav *.mp3 *.flac)"]
        onAccepted: {
            var filePath = selectedFile.toString()
            if (filePath.indexOf("file:///") === 0) {
                filePath = filePath.substring(8)
            }
            if (characterComboBox.currentIndex >= 0) {
                var character = root.characterOptions[characterComboBox.currentIndex]
                var englishName = character.englishName
                var result = voiceLibrary.importVoiceMaterial(filePath, englishName)
                if (result !== "") {
                    voiceMaterialEdit.text = result
                    logger.logInfo("素材文件已上传到: " + result)
                } else {
                    logger.logError("上传素材文件失败")
                    voiceMaterialEdit.text = filePath
                }
            } else {
                voiceMaterialEdit.text = filePath
            }
        }
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        Rectangle {
            Layout.preferredWidth: 180
            Layout.fillHeight: true
            color: "#FAFAFA"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "#FFFFFF"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "声音库"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }
                }
                
                ListView {
                    id: voiceListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: voiceLibrary ? voiceLibrary.voiceList : []
                    currentIndex: root.currentVoiceIndex
                    clip: true
                    
                    delegate: Rectangle {
                        width: voiceListView.width
                        height: 50
                        color: {
                            if (voiceListView.currentIndex === index) return "#E6F7FF"
                            if (voiceHoverArea.containsMouse) return "#F0F0F0"
                            return "#FFFFFF"
                        }
                        
                        MouseArea {
                            id: voiceHoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                voiceListView.currentIndex = index
                                root.currentVoiceIndex = index
                                root.isCreatingNew = false
                            }
                        }
                        
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name
                            font.pixelSize: 14
                            color: "#333333"
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#E8E8E8"
                }
                
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.margins: 10
                    
                    background: Rectangle {
                        color: parent.hovered ? "#40A9FF" : "#1890FF"
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: "+ 新增声音"
                        font.pixelSize: 14
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        root.isCreatingNew = true
                        root.currentVoiceIndex = -1
                        voiceListView.currentIndex = -1
                    }
                }
                
                Button {
                    id: queryCloudButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.bottomMargin: 10
                    
                    background: Rectangle {
                        color: {
                            if (!parent.enabled) return "#BFBFBF"
                            return parent.hovered ? "#73D13D" : "#52C41A"
                        }
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: queryCloudButton.enabled ? "查询云端声音" : "查询中..."
                        font.pixelSize: 14
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        if (typeof pythonRunner === "undefined" || !pythonRunner) {
                            logger.logError("pythonRunner 未注册")
                            return
                        }
                        
                        queryCloudButton.enabled = false
                        
                        try {
                            var success = pythonRunner.runScript("voice_clone", ["list"])
                            
                            if (success) {
                                var output = pythonRunner.getOutput().trim()
                                voiceLibrary.updateCloudVoices(output)
                                cloudVoiceDialog.open()
                                logger.logInfo("查询到 " + (voiceLibrary ? voiceLibrary.cloudVoiceCount() : 0) + " 个云端声音")
                            } else {
                                logger.logError("查询云端声音失败: " + pythonRunner.getError())
                            }
                        } catch (e) {
                            logger.logError("查询云端声音失败: " + e.toString())
                        } finally {
                            queryCloudButton.enabled = true
                        }
                    }
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFFFFF"
            
            Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: contentColumn.implicitHeight
                clip: true
                
                ColumnLayout {
                    id: contentColumn
                    width: parent.width
                    spacing: 20
                    
                    Item { Layout.preferredHeight: 20 }
                    
                    Text {
                        Layout.leftMargin: 30
                        text: root.isCreatingNew ? "新增声音" : (root.currentVoiceIndex >= 0 ? "声音详情" : "请选择声音")
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333333"
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 30
                        Layout.rightMargin: 30
                        Layout.preferredHeight: 1
                        color: "#E8E8E8"
                    }
                    
                    Item { Layout.preferredHeight: 10 }
                    
                    ColumnLayout {
                        Layout.leftMargin: 30
                        Layout.rightMargin: 30
                        spacing: 15
                        visible: root.isCreatingNew
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "模型:"
                                font.pixelSize: 14
                                color: "#333333"
                                Layout.preferredWidth: 80
                            }
                            
                            Text {
                                text: "cosyvoice-v3.5-plus"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#1890FF"
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "角色:"
                                font.pixelSize: 14
                                color: "#333333"
                                Layout.preferredWidth: 80
                            }
                            
                            ComboBox {
                                id: characterComboBox
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                model: root.characterOptions
                                
                                textRole: ""
                                
                                delegate: ItemDelegate {
                                    width: characterComboBox.width
                                    height: 40
                                    contentItem: Text {
                                        text: modelData.chineseName + " (" + modelData.englishName + ")"
                                        font.pixelSize: 14
                                        color: "#333333"
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 10
                                    }
                                    highlighted: characterComboBox.highlightedIndex === index
                                }
                                
                                contentItem: Text {
                                    leftPadding: 10
                                    rightPadding: 30
                                    text: characterComboBox.characterDisplayText
                                    font.pixelSize: 14
                                    color: "#333333"
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                                
                                indicator: Canvas {
                                    x: characterComboBox.width - width - characterComboBox.rightPadding
                                    y: (characterComboBox.availableHeight - height) / 2
                                    width: 12
                                    height: 8
                                    contextType: "2d"
                                    onPaint: {
                                        context.reset()
                                        context.moveTo(0, 0)
                                        context.lineTo(width, 0)
                                        context.lineTo(width / 2, height)
                                        context.closePath()
                                        context.fillStyle = "#666666"
                                        context.fill()
                                    }
                                }
                                
                                background: Rectangle {
                                    color: "#FFFFFF"
                                    border.color: "#D9D9D9"
                                    border.width: 1
                                    radius: 4
                                }
                                
                                Component.onCompleted: {
                                    updateDisplayText()
                                }
                                
                                onCurrentIndexChanged: {
                                    updateDisplayText()
                                }
                                
                                function updateDisplayText() {
                                    if (currentIndex >= 0 && currentIndex < root.characterOptions.length) {
                                        var item = root.characterOptions[currentIndex]
                                        characterDisplayText = item.chineseName + " (" + item.englishName + ")"
                                    }
                                }
                                
                                property string characterDisplayText: ""
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "上传素材:"
                                font.pixelSize: 14
                                color: "#333333"
                                Layout.preferredWidth: 80
                            }
                            
                            TextField {
                                id: voiceMaterialEdit
                                Layout.fillWidth: true
                                placeholderText: "上传声音素材文件"
                                font.pixelSize: 14
                                readOnly: true
                            }
                            
                            Button {
                                text: "上传文件"
                                font.pixelSize: 12
                                
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
                                    voiceMaterialFileDialog.open()
                                }
                            }
                        }
                        
                        Item { Layout.preferredHeight: 10 }
                        
                        Button {
                            id: cloneButton
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignHCenter
                            
                            background: Rectangle {
                                color: {
                                    if (!parent.enabled) return "#BFBFBF"
                                    return parent.hovered ? "#FF7875" : "#FF4D4F"
                                }
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "#FFFFFF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            text: "开始复刻"
                            
                            onClicked: {
                                if (characterComboBox.currentIndex < 0) {
                                    logger.logWarning("请选择角色")
                                    return
                                }
                                
                                var character = root.characterOptions[characterComboBox.currentIndex]
                                var englishName = character.englishName
                                var wavPath = voiceLibrary.voiceMaterialPath(englishName)
                                if (wavPath === "") {
                                    logger.logWarning("请先上传素材文件")
                                    return
                                }
                                
                                if (typeof pythonRunner === "undefined" || !pythonRunner) {
                                    logger.logError("pythonRunner 未注册")
                                    return
                                }
                                
                                cloneButton.enabled = false
                                cloneButton.text = "复刻中..."
                                
                                try {
                                    var success = pythonRunner.runScript("voice_clone", [
                                        "clone", "--wav", wavPath,
                                        "--name", englishName
                                    ])
                                    
                                    if (success) {
                                        var voiceId = pythonRunner.getOutput()
                                        voiceLibrary.addVoice(voiceId, character.chineseName + " (" + englishName + ")", englishName)
                                        logger.logInfo("声音复刻成功: " + voiceId)
                                        
                                        root.isCreatingNew = false
                                        voiceMaterialEdit.text = ""
                                        characterComboBox.currentIndex = -1
                                    } else {
                                        logger.logError("声音复刻失败: " + pythonRunner.getError())
                                    }
                                } catch (e) {
                                    console.error("声音复刻错误:", e)
                                    logger.logError("声音复刻失败: " + e.toString())
                                } finally {
                                    cloneButton.enabled = true
                                    cloneButton.text = "开始复刻"
                                }
                            }
                        }
                    }
                    
                    ColumnLayout {
                        Layout.leftMargin: 30
                        Layout.rightMargin: 30
                        spacing: 15
                        visible: !root.isCreatingNew && root.currentVoiceIndex >= 0
                        
                        property var currentVoice: root.currentVoiceIndex >= 0 && voiceLibrary ? voiceLibrary.voiceList[root.currentVoiceIndex] : null
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "声音ID:"
                                font.pixelSize: 14
                                color: "#666666"
                                Layout.preferredWidth: 80
                            }
                            
                            Text {
                                text: parent.parent.currentVoice ? parent.parent.currentVoice.voiceId : ""
                                font.pixelSize: 14
                                color: "#333333"
                                font.family: "Consolas, Monaco, monospace"
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "名称:"
                                font.pixelSize: 14
                                color: "#666666"
                                Layout.preferredWidth: 80
                            }
                            
                            Text {
                                text: parent.parent.currentVoice ? parent.parent.currentVoice.name : ""
                                font.pixelSize: 14
                                color: "#333333"
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "创建时间:"
                                font.pixelSize: 14
                                color: "#666666"
                                Layout.preferredWidth: 80
                            }
                            
                            Text {
                                text: parent.parent.currentVoice ? parent.parent.currentVoice.createdAt : ""
                                font.pixelSize: 14
                                color: "#333333"
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "#E8E8E8"
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "试听文本:"
                                font.pixelSize: 14
                                color: "#333333"
                                Layout.preferredWidth: 80
                            }
                            
                            TextField {
                                id: testTextEdit
                                Layout.fillWidth: true
                                placeholderText: "输入试听文本"
                                font.pixelSize: 14
                            }
                            
                            Button {
                                id: synthesizeButton
                                text: "合成"
                                font.pixelSize: 12
                                
                                background: Rectangle {
                                    color: {
                                        if (!parent.enabled) return "#BFBFBF"
                                        return parent.hovered ? "#40A9FF" : "#1890FF"
                                    }
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
                                    var voice = voiceLibrary.voiceList[root.currentVoiceIndex]
                                    var voiceId = voice.voiceId
                                    var characterName = voice.characterName
                                    var text = testTextEdit.text.trim()
                                    
                                    if (text === "") {
                                        logger.logWarning("请输入试听文本")
                                        return
                                    }
                                    
                                    if (typeof pythonRunner === "undefined" || !pythonRunner) {
                                        logger.logError("pythonRunner 未注册")
                                        return
                                    }
                                    
                                    var outputPath = voiceLibrary.voiceDir(characterName) + "/output.mp3"
                                    
                                    synthesizeButton.enabled = false
                                    synthesizeButton.text = "合成中..."
                                    
                                    try {
                                        var success = pythonRunner.runScript("voice_clone", [
                                            "synthesize", "--voice", voiceId,
                                            "--text", text,
                                            "--output", outputPath
                                        ])
                                        
                                        if (success) {
                                            logger.logInfo("语音合成成功: " + outputPath)
                                        } else {
                                            logger.logError("语音合成失败: " + pythonRunner.getError())
                                        }
                                    } catch (e) {
                                        console.error("语音合成错误:", e)
                                        logger.logError("语音合成失败: " + e.toString())
                                    } finally {
                                        synthesizeButton.enabled = true
                                        synthesizeButton.text = "合成"
                                    }
                                }
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15
                            
                            Button {
                                id: previewButton
                                text: previewPlayer.playbackState === MediaPlayer.PlayingState ? "停止" : "播放"
                                font.pixelSize: 12
                                Layout.preferredWidth: 80
                                
                                background: Rectangle {
                                    color: {
                                        if (previewPlayer.playbackState === MediaPlayer.PlayingState)
                                            return parent.hovered ? "#FF7875" : "#FF4D4F"
                                        return parent.hovered ? "#40A9FF" : "#1890FF"
                                    }
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
                                    if (previewPlayer.playbackState === MediaPlayer.PlayingState) {
                                        previewPlayer.stop()
                                    } else {
                                        var voice = voiceLibrary.voiceList[root.currentVoiceIndex]
                                        var previewPath = voiceLibrary.voiceDir(voice.characterName) + "/output.mp3"
                                        previewPlayer.source = "file:///" + previewPath
                                        previewPlayer.play()
                                    }
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Button {
                                id: deleteButton
                                text: "删除声音"
                                font.pixelSize: 12
                                Layout.preferredWidth: 100
                                
                                background: Rectangle {
                                    color: parent.hovered ? "#FFA39E" : "#FF4D4F"
                                    radius: 4
                                    border.color: "#FF4D4F"
                                    border.width: 1
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: "#FF4D4F"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: {
                                    deleteConfirmDialog.open()
                                }
                            }
                        }
                    }
                    
                    Item { Layout.preferredHeight: 30 }
                }
            }
        }
    }
    
    Dialog {
        id: deleteConfirmDialog
        title: "确认删除"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        
        anchors.centerIn: parent
        width: 300
        
        Text {
            text: "确定要删除这个声音吗？"
            font.pixelSize: 14
        }
        
        onAccepted: {
            if (root.currentVoiceIndex >= 0) {
                voiceLibrary.removeVoice(root.currentVoiceIndex)
                root.currentVoiceIndex = -1
            }
        }
    }
    
    Dialog {
        id: cloudVoiceDialog
        title: "云端声音列表"
        modal: true
        standardButtons: Dialog.Close
        
        anchors.centerIn: parent
        width: 700
        height: 450
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: "共 " + (voiceLibrary ? voiceLibrary.cloudVoiceCount() : 0) + " 个声音"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333333"
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    id: deleteAllCloudButton
                    text: "全选删除"
                    font.pixelSize: 12
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 30
                    enabled: voiceLibrary ? voiceLibrary.cloudVoiceCount() > 0 : false
                    
                    background: Rectangle {
                        color: {
                            if (!parent.enabled) return "#BFBFBF"
                            return parent.hovered ? "#FF7875" : "#FF4D4F"
                        }
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
                        cloudDeleteAllConfirmDialog.open()
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.color: "#E8E8E8"
                border.width: 1
                radius: 4
                
                ListView {
                    anchors.fill: parent
                    anchors.margins: 1
                    model: voiceLibrary ? voiceLibrary.cloudVoiceList : []
                    clip: true
                    
                    header: Rectangle {
                        width: ListView.view.width
                        height: 36
                        color: "#FAFAFA"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 0
                            
                            Text {
                                Layout.preferredWidth: 260
                                text: "Voice ID"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#666666"
                            }
                            
                            Text {
                                Layout.preferredWidth: 120
                                text: "模型"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#666666"
                            }
                            
                            Text {
                                Layout.preferredWidth: 130
                                text: "创建时间"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#666666"
                            }
                            
                            Text {
                                Layout.preferredWidth: 50
                                text: "状态"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#666666"
                            }
                            
                            Text {
                                Layout.preferredWidth: 50
                                text: "操作"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#666666"
                            }
                        }
                    }
                    
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 36
                        color: index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 0
                            
                            Text {
                                Layout.preferredWidth: 260
                                text: modelData.voice_id || ""
                                font.pixelSize: 11
                                font.family: "Consolas, Monaco, monospace"
                                color: "#333333"
                                elide: Text.ElideRight
                            }
                            
                            Text {
                                Layout.preferredWidth: 120
                                text: modelData.target_model || ""
                                font.pixelSize: 12
                                color: "#666666"
                                elide: Text.ElideRight
                            }
                            
                            Text {
                                Layout.preferredWidth: 130
                                text: modelData.gmt_create || ""
                                font.pixelSize: 12
                                color: "#666666"
                                elide: Text.ElideRight
                            }
                            
                            Text {
                                Layout.preferredWidth: 50
                                text: modelData.status || ""
                                font.pixelSize: 12
                                color: modelData.status === "OK" ? "#52C41A" : "#FF4D4F"
                                elide: Text.ElideRight
                            }
                            
                            Button {
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 26
                                text: "删除"
                                font.pixelSize: 11
                                
                                background: Rectangle {
                                    color: parent.hovered ? "#FF7875" : "#FF4D4F"
                                    radius: 3
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: "#FFFFFF"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: {
                                    root.pendingDeleteCloudVoiceId = modelData.voice_id || ""
                                    cloudDeleteConfirmDialog.open()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    Dialog {
        id: cloudDeleteConfirmDialog
        title: "确认删除"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        
        anchors.centerIn: parent
        width: 400
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            
            Text {
                text: "确定要从云端删除这个声音吗？"
                font.pixelSize: 14
                color: "#333333"
            }
            
            Text {
                text: root.pendingDeleteCloudVoiceId
                font.pixelSize: 12
                font.family: "Consolas, Monaco, monospace"
                color: "#999999"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
        
        onAccepted: {
            if (typeof pythonRunner === "undefined" || !pythonRunner) {
                logger.logError("pythonRunner 未注册")
                return
            }
            
            var voiceId = root.pendingDeleteCloudVoiceId
            if (voiceId === "") {
                logger.logWarning("未选择要删除的声音")
                return
            }
            
            try {
                var success = pythonRunner.runScript("voice_clone", [
                    "delete", "--voice-id", voiceId
                ])
                
                if (success) {
                    logger.logInfo("云端声音删除成功: " + voiceId)
                    pythonRunner.runScript("voice_clone", ["list"])
                    if (pythonRunner.getOutput().trim() !== "") {
                        voiceLibrary.updateCloudVoices(pythonRunner.getOutput().trim())
                    }
                } else {
                    logger.logError("云端声音删除失败: " + pythonRunner.getError())
                }
            } catch (e) {
                logger.logError("云端声音删除失败: " + e.toString())
            }
            
            root.pendingDeleteCloudVoiceId = ""
        }
        
        onRejected: {
            root.pendingDeleteCloudVoiceId = ""
        }
    }
    
    Dialog {
        id: cloudDeleteAllConfirmDialog
        title: "确认全选删除"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        
        anchors.centerIn: parent
        width: 400
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            
            Text {
                text: "确定要删除云端所有声音吗？此操作不可恢复！"
                font.pixelSize: 14
                font.bold: true
                color: "#FF4D4F"
            }
            
            Text {
                text: "将删除 " + (voiceLibrary ? voiceLibrary.cloudVoiceCount() : 0) + " 个声音"
                font.pixelSize: 13
                color: "#333333"
            }
        }
        
        onAccepted: {
            if (typeof pythonRunner === "undefined" || !pythonRunner) {
                logger.logError("pythonRunner 未注册")
                return
            }
            
            var voices = voiceLibrary ? voiceLibrary.cloudVoiceList : []
            var totalCount = voices.length
            var successCount = 0
            var failCount = 0
            
            for (var i = 0; i < totalCount; i++) {
                var voiceId = voices[i].voice_id
                if (!voiceId) continue
                
                try {
                    var success = pythonRunner.runScript("voice_clone", [
                        "delete", "--voice-id", voiceId
                    ])
                    
                    if (success) {
                        successCount++
                        logger.logInfo("删除成功: " + voiceId)
                    } else {
                        failCount++
                        logger.logError("删除失败: " + voiceId + " - " + pythonRunner.getError())
                    }
                } catch (e) {
                    failCount++
                    logger.logError("删除异常: " + voiceId + " - " + e.toString())
                }
            }
            
            logger.logInfo("全选删除完成: 成功 " + successCount + " 个, 失败 " + failCount + " 个")
            
            var listSuccess = pythonRunner.runScript("voice_clone", ["list"])
            if (listSuccess && pythonRunner.getOutput().trim() !== "") {
                voiceLibrary.updateCloudVoices(pythonRunner.getOutput().trim())
            }
        }
    }
}
