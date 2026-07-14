import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    color: "#FFFFFF"
    
    Dialog {
        id: avatarDialog
        title: "更换头像"
        modal: true
        anchors.centerIn: parent
        
        ColumnLayout {
            spacing: 10
            
            Text {
                text: "请选择头像文件:"
                font.pixelSize: 14
                color: "#333333"
            }
            
            Button {
                text: "选择图片"
                font.pixelSize: 14
                
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
                    avatarFileDialog.open()
                }
            }
            
            Button {
                text: "取消"
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
                    avatarDialog.close()
                }
            }
        }
    }
    
    FileDialog {
        id: avatarFileDialog
        title: "选择头像图片"
        nameFilters: ["图片文件 (*.png *.jpg *.jpeg)"]
        onAccepted: {
            var filePath = selectedFile.toString()
            console.log("FileDialog selected:", filePath)
            avatarCropDialog.sourceImagePath = filePath
            avatarCropDialog.open()
        }
    }
    
    Dialog {
        id: avatarCropDialog
        title: "调整头像"
        modal: true
        anchors.centerIn: parent
        width: 320
        height: 420
        
        property string sourceImagePath: ""
        property real scaleValue: 1.0
        property real offsetX: 0
        property real offsetY: 0
        
        onOpened: {
            console.log("avatarCropDialog opened with source:", sourceImagePath)
            scaleValue = 1.0
            offsetX = 0
            offsetY = 0
            console.log("Reset scale to 1.0, offset to (0, 0)")
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 15
            
            Item {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200
                Layout.alignment: Qt.AlignHCenter
                
                Rectangle {
                    anchors.fill: parent
                    radius: 100
                    color: "#F0F0F0"
                }
                
                Rectangle {
                    id: clipMask
                    anchors.fill: parent
                    radius: 100
                    clip: true
                    color: "transparent"
                    
                    Image {
                        id: cropImage
                        width: parent.width
                        height: parent.height
                        source: avatarCropDialog.sourceImagePath
                        fillMode: Image.PreserveAspectCrop
                        scale: avatarCropDialog.scaleValue
                        x: (parent.width - width) / 2 + avatarCropDialog.offsetX
                        y: (parent.height - height) / 2 + avatarCropDialog.offsetY
                        
                        onStatusChanged: {
                            if (status === Image.Ready) {
                                console.log("Image loaded:", source, "size:", sourceSize)
                            } else if (status === Image.Error) {
                                console.log("Image load error:", source)
                            }
                        }
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    radius: 100
                    color: "transparent"
                    border.color: "#1890FF"
                    border.width: 2
                }
                
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
                            console.log("Dragging: dx=", dx, "dy=", dy, "old offset=", avatarCropDialog.offsetX, avatarCropDialog.offsetY)
                            avatarCropDialog.offsetX += dx
                            avatarCropDialog.offsetY += dy
                            lastPos = Qt.point(mouseX, mouseY)
                            console.log("New offset:", avatarCropDialog.offsetX, avatarCropDialog.offsetY)
                        }
                    }
                    
                    onReleased: {
                        console.log("MouseArea released")
                        dragging = false
                        cursorShape = Qt.OpenHandCursor
                    }
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: "缩放:"
                    font.pixelSize: 12
                    color: "#666666"
                }
                
                Slider {
                    id: scaleSlider
                    Layout.fillWidth: true
                    from: 0.5
                    to: 3.0
                    value: 1.0
                    stepSize: 0.1
                    
                    onValueChanged: {
                        avatarCropDialog.scaleValue = value
                        console.log("Scale changed to:", value)
                    }
                }
                
                Text {
                    text: scaleSlider.value.toFixed(1)
                    font.pixelSize: 12
                    color: "#666666"
                    Layout.preferredWidth: 30
                }
            }
            
            Text {
                text: "拖拽移动图片，滑块调整缩放"
                font.pixelSize: 11
                color: "#999999"
                Layout.alignment: Qt.AlignHCenter
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "确定"
                    font.pixelSize: 14
                    
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
                            if (avatarCropDialog.sourceImagePath === "") {
                                logger.logWarning("未选择头像图片")
                                return
                            }
                            
                            var inputPath = avatarCropDialog.sourceImagePath
                            console.log("原始路径:", inputPath)
                            
                            if (inputPath.startsWith("file:///")) {
                                inputPath = inputPath.substring(8)
                            } else if (inputPath.startsWith("file://")) {
                                inputPath = inputPath.substring(7)
                            }
                            
                            if (inputPath.length > 2 && inputPath.charAt(0) === "/" && inputPath.charAt(2) === ":") {
                                inputPath = inputPath.substring(1)
                            }
                            
                            console.log("转换后路径:", inputPath)
                            
                            if (!characterManager.ensureUserDir()) {
                                logger.logError("无法创建用户头像目录")
                                return
                            }
                            
                            var userDir = characterManager.userDir()
                            var pngPath = userDir + "/user.png"
                            var binPath = userDir + "/user.bin"
                            
                            console.log("userDir:", userDir)
                            console.log("pngPath:", pngPath)
                            console.log("binPath:", binPath)
                            console.log("offsetX:", avatarCropDialog.offsetX, "offsetY:", avatarCropDialog.offsetY)
                            console.log("scaleValue:", avatarCropDialog.scaleValue)
                            logger.logInfo("开始处理用户头像: " + pngPath)
                            
                            if (typeof imageProcessor === "undefined" || !imageProcessor) {
                                logger.logError("imageProcessor 未注册")
                                return
                            }
                            
                            if (typeof imageProcessor.cropCircular !== "function") {
                                logger.logError("cropCircular 函数不存在")
                                return
                            }
                            
                            var success = imageProcessor.cropCircular(
                                inputPath,
                                pngPath,
                                60,
                                avatarCropDialog.offsetX,
                                avatarCropDialog.offsetY,
                                avatarCropDialog.scaleValue,
                                200
                            )
                            
                            console.log("cropCircular 返回:", success)
                            
                            if (success) {
                                logger.logInfo("PNG裁剪成功，开始转换为BIN...")
                                
                                if (typeof pythonRunner === "undefined" || !pythonRunner) {
                                    logger.logError("pythonRunner 未注册")
                                    return
                                }
                                
                                var binSuccess = pythonRunner.runScript("convert_image", [
                                    "--type", "avatar",
                                    "--input", pngPath,
                                    "--output", binPath
                                ])
                                
                                console.log("runScript 返回:", binSuccess)
                                
                                if (binSuccess) {
                                    logger.logInfo("用户头像处理完成: " + binPath)
                                    characterManager.incrementAvatarVersion()
                                    avatarCropDialog.close()
                                } else {
                                    logger.logError("BIN转换失败: " + pythonRunner.getOutput())
                                }
                            } else {
                                logger.logError("PNG裁剪失败")
                            }
                        } catch (e) {
                            console.error("头像处理错误:", e)
                            logger.logError("处理失败: " + e.toString())
                        }
                    }
                }
                
                Button {
                    text: "取消"
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
                        avatarCropDialog.close()
                    }
                }
            }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: 40
                color: "#CCCCCC"
                clip: true
                
                Image {
                    anchors.fill: parent
                    source: {
                        if (!characterManager) return ""
                        var path = characterManager.userAvatarPath()
                        if (path !== "") return "file:///" + path + "?v=" + characterManager.avatarVersion
                        return ""
                    }
                    fillMode: Image.PreserveAspectCrop
                    visible: source !== ""
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "U"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#FFFFFF"
                    visible: parent.children[0].source === ""
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        avatarDialog.open()
                    }
                }
            }
        }
        
        Text {
            text: "账号配置"
            font.pixelSize: 18
            font.bold: true
            color: "#333333"
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: "服务商:"
                font.pixelSize: 14
                color: "#333333"
            }
            
            Text {
                text: "阿里百炼"
                font.pixelSize: 14
                font.bold: true
                color: "#1890FF"
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: "API-KEY:"
                font.pixelSize: 14
                color: "#333333"
            }
            
            TextField {
                id: apiKeyField
                Layout.fillWidth: true
                placeholderText: "请输入API-KEY"
                font.pixelSize: 14
                text: userAccount && userAccount.apiKey ? userAccount.apiKey : ""
                visible: apiKeyEditBtn.checked
            }
            
            Text {
                Layout.fillWidth: true
                font.pixelSize: 14
                color: "#333333"
                visible: !apiKeyEditBtn.checked
                text: {
                    var key = userAccount && userAccount.apiKey ? userAccount.apiKey : ""
                    if (!key || key.length <= 10) return key || ""
                    return key.substring(0, 6) + "*".repeat(key.length - 10) + key.substring(key.length - 4)
                }
            }
            
            Button {
                id: apiKeyEditBtn
                text: checked ? "完成" : "编辑"
                font.pixelSize: 14
                checkable: true
                checked: false
                
                background: Rectangle {
                    color: parent.hovered ? "#40A9FF" : (parent.checked ? "#52C41A" : "#1890FF")
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onCheckedChanged: {
                    if (!checked && userAccount) {
                        userAccount.apiKey = apiKeyField.text
                        userAccount.saveConfig()
                    }
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: "Workspace-ID:"
                font.pixelSize: 14
                color: "#333333"
            }
            
            TextField {
                id: workspaceIdField
                Layout.fillWidth: true
                placeholderText: "请输入Workspace-ID"
                font.pixelSize: 14
                text: userAccount && userAccount.workspaceId ? userAccount.workspaceId : ""
                visible: workspaceIdEditBtn.checked
            }
            
            Text {
                Layout.fillWidth: true
                font.pixelSize: 14
                color: "#333333"
                visible: !workspaceIdEditBtn.checked
                text: {
                    var wid = userAccount && userAccount.workspaceId ? userAccount.workspaceId : ""
                    if (!wid || wid.length <= 10) return wid || ""
                    return wid.substring(0, 6) + "*".repeat(wid.length - 10) + wid.substring(wid.length - 4)
                }
            }
            
            Button {
                id: workspaceIdEditBtn
                text: checked ? "完成" : "编辑"
                font.pixelSize: 14
                checkable: true
                checked: false
                
                background: Rectangle {
                    color: parent.hovered ? "#40A9FF" : (parent.checked ? "#52C41A" : "#1890FF")
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onCheckedChanged: {
                    if (!checked && userAccount) {
                        userAccount.workspaceId = workspaceIdField.text
                        userAccount.saveConfig()
                    }
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: "获取API-KEY:"
                font.pixelSize: 14
                color: "#333333"
            }
            
            Button {
                text: "打开阿里百炼控制台"
                font.pixelSize: 14
                
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
                    Qt.openUrlExternally("https://bailian.console.aliyun.com/cn-beijing?spm=5176.45897547.0.0.20574e76OOK2D4&nav-v2-dropdown-menu-0.d_main_2_0_0.55fb3c60193rCE=&tab=model#/api-key")
                }
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
    }
}