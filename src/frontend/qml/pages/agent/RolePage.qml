import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    color: "#FFFFFF"
    
    property bool nfcGenerated: false
    property string nfcResult: ""
    property int pendingDeleteIndex: -1
    
    property var currentRole: characterManager && roleListView.currentIndex >= 0 && roleListView.currentIndex < characterManager.roleCount ? characterManager.roleList[roleListView.currentIndex] : null
    
    function currentEnglishName() {
        // 直接从 backend 获取最新的英文名，避免使用过期的 currentRole 快照
        if (characterManager && roleListView.currentIndex >= 0) {
            var roles = characterManager.getRoleList()
            if (roleListView.currentIndex < roles.length) {
                var role = roles[roleListView.currentIndex]
                if (role && role.englishName)
                    return role.englishName.trim()
            }
        }
        return ""
    }
    
    Dialog {
        id: addRoleDialog
        title: "添加角色"
        modal: true
        anchors.centerIn: parent
        
        ColumnLayout {
            spacing: 10
            
            Text {
                text: "请输入角色名称:"
                font.pixelSize: 14
                color: "#333333"
            }
            
            TextField {
                id: roleNameInput
                Layout.preferredWidth: 200
                placeholderText: "角色名称"
                font.pixelSize: 14
            }
            
            RowLayout {
                spacing: 10
                
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
                        if (roleNameInput.text.trim() !== "") {
                            characterManager.addRole(roleNameInput.text.trim())
                            roleNameInput.text = ""
                            addRoleDialog.close()
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
                        roleNameInput.text = ""
                        addRoleDialog.close()
                    }
                }
            }
        }
        
        onOpened: {
            roleNameInput.forceActiveFocus()
        }
    }
    
    Dialog {
        id: deleteConfirmDialog
        title: "确认删除"
        modal: true
        anchors.centerIn: parent
        
        ColumnLayout {
            spacing: 10
            
            Text {
                text: "确定要删除该角色吗？相关资源文件将一并删除。"
                font.pixelSize: 14
                color: "#333333"
            }
            
            RowLayout {
                spacing: 10
                
                Button {
                    text: "确定"
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
                        if (pendingDeleteIndex >= 0) {
                            characterManager.removeRole(pendingDeleteIndex)
                            pendingDeleteIndex = -1
                            if (roleListView.currentIndex >= characterManager.roleCount) {
                                roleListView.currentIndex = characterManager.roleCount - 1
                            }
                        }
                        deleteConfirmDialog.close()
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
                        pendingDeleteIndex = -1
                        deleteConfirmDialog.close()
                    }
                }
            }
        }
    }
    
    Dialog {
        id: englishNameRequiredDialog
        title: "提示"
        modal: true
        anchors.centerIn: parent
        width: 300
        
        ColumnLayout {
            spacing: 15
            
            Text {
                text: "请先设置角色英文名后再更换头像"
                font.pixelSize: 14
                color: "#333333"
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
            
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
                    englishNameRequiredDialog.close()
                }
            }
        }
    }
    
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
        nameFilters: ["PNG 图片 (*.png)"]
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
            
            // 圆形预览区域
            Item {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200
                Layout.alignment: Qt.AlignHCenter
                
                // 背景
                Rectangle {
                    anchors.fill: parent
                    radius: 100
                    color: "#F0F0F0"
                }
                
                // 裁剪层
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
                        // 手动计算居中位置 + 偏移
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
                
                // 圆形蒙版边框（上层）
                Rectangle {
                    anchors.fill: parent
                    radius: 100
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
                            var englishName = currentEnglishName()
                            var roleName = currentRole ? currentRole.name : ""
                            
                            console.log("englishName:", englishName, "roleName:", roleName)
                            
                            if (englishName === "" || roleName === "") {
                                logger.logWarning("请先设置角色英文名")
                                return
                            }
                            
                            if (avatarCropDialog.sourceImagePath === "") {
                                logger.logWarning("未选择头像图片")
                                return
                            }
                            
                            // 转换 URL 为本地路径
                            var inputPath = avatarCropDialog.sourceImagePath
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
                            var roleDir = characterManager.roleDir(roleName)
                            var pngPath = roleDir + "/" + englishName + ".png"
                            var binPath = roleDir + "/" + englishName + ".bin"
                            
                            console.log("roleDir:", roleDir)
                            console.log("pngPath:", pngPath)
                            console.log("binPath:", binPath)
                            console.log("offsetX:", avatarCropDialog.offsetX, "offsetY:", avatarCropDialog.offsetY)
                            console.log("scaleValue:", avatarCropDialog.scaleValue)
                            logger.logInfo("开始处理头像: " + pngPath)
                            
                            // 验证 imageProcessor 是否存在
                            if (typeof imageProcessor === "undefined" || !imageProcessor) {
                                logger.logError("imageProcessor 未注册")
                                return
                            }
                            
                            if (typeof imageProcessor.cropCircular !== "function") {
                                logger.logError("cropCircular 函数不存在")
                                return
                            }
                            
                            // 调用 C++ 裁剪生成 PNG
                            var success = imageProcessor.cropCircular(
                                inputPath,
                                pngPath,
                                60,  // targetSize
                                avatarCropDialog.offsetX,
                                avatarCropDialog.offsetY,
                                avatarCropDialog.scaleValue,
                                200  // previewSize (matches the 200x200 preview area)
                            )
                            
                            console.log("cropCircular 返回:", success)
                            
                            if (success) {
                                logger.logInfo("PNG裁剪成功，开始转换为BIN...")
                                
                                // 验证 pythonRunner 是否存在
                                if (typeof pythonRunner === "undefined" || !pythonRunner) {
                                    logger.logError("pythonRunner 未注册")
                                    return
                                }
                                
                                // 调用 Python 转换为 BIN
                                var binSuccess = pythonRunner.runScript("convert_image", [
                                    "--type", "avatar",
                                    "--input", pngPath,
                                    "--output", binPath
                                ])
                                
                                console.log("runScript 返回:", binSuccess)
                                
                                if (binSuccess) {
                                    logger.logInfo("头像处理完成: " + binPath)
                                    var savedIndex = roleListView.currentIndex
                                    characterManager.incrementAvatarVersion()
                                    // 强制刷新角色列表以更新头像显示
                                    roleListView.model = null
                                    roleListView.model = characterManager.roleList
                                    // 恢复 currentIndex 防止跳转到第一个角色
                                    roleListView.currentIndex = savedIndex
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
    
    Dialog {
        id: chatBgCropDialog
        title: "调整聊天背景"
        modal: true
        anchors.centerIn: parent
        width: 400
        height: 480
        
        property string sourceImagePath: ""
        property real scaleValue: 1.0
        property real offsetX: 0
        property real offsetY: 0
        
        onOpened: {
            console.log("chatBgCropDialog opened with source:", sourceImagePath)
            scaleValue = 1.0
            offsetX = 0
            offsetY = 0
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 15
            
            // 280x171 预览区域（保持宽高比）
            Item {
                Layout.preferredWidth: 280
                Layout.preferredHeight: 171
                Layout.alignment: Qt.AlignHCenter
                
                Rectangle {
                    anchors.fill: parent
                    color: "#F0F0F0"
                    border.color: "#D9D9D9"
                    border.width: 1
                }
                
                Rectangle {
                    id: chatBgClipMask
                    anchors.fill: parent
                    color: "transparent"
                    clip: true
                    
                    Image {
                        id: chatBgCropImage
                        width: parent.width
                        height: parent.height
                        source: chatBgCropDialog.sourceImagePath
                        fillMode: Image.PreserveAspectCrop
                        scale: chatBgCropDialog.scaleValue
                        x: (parent.width - width) / 2 + chatBgCropDialog.offsetX
                        y: (parent.height - height) / 2 + chatBgCropDialog.offsetY
                        
                        onStatusChanged: {
                            if (status === Image.Ready) {
                                console.log("Chat background image loaded:", source, "size:", sourceSize)
                            } else if (status === Image.Error) {
                                console.log("Chat background image load error:", source)
                            }
                        }
                    }
                }
                
                // 边框（上层）
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
                        console.log("ChatBg MouseArea pressed at:", mouseX, mouseY)
                        dragging = true
                        lastPos = Qt.point(mouseX, mouseY)
                        cursorShape = Qt.ClosedHandCursor
                    }
                    
                    onPositionChanged: {
                        if (dragging) {
                            var dx = mouseX - lastPos.x
                            var dy = mouseY - lastPos.y
                            console.log("Dragging: dx=", dx, "dy=", dy, "old offset=", chatBgCropDialog.offsetX, chatBgCropDialog.offsetY)
                            chatBgCropDialog.offsetX += dx
                            chatBgCropDialog.offsetY += dy
                            lastPos = Qt.point(mouseX, mouseY)
                            console.log("New offset:", chatBgCropDialog.offsetX, chatBgCropDialog.offsetY)
                        }
                    }
                    
                    onReleased: {
                        console.log("ChatBg MouseArea released")
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
                    id: chatBgScaleSlider
                    Layout.fillWidth: true
                    from: 0.5
                    to: 3.0
                    value: 1.0
                    stepSize: 0.1
                    
                    onValueChanged: {
                        chatBgCropDialog.scaleValue = value
                        console.log("Scale changed to:", value)
                    }
                }
                
                Text {
                    text: chatBgScaleSlider.value.toFixed(1)
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
                            var name = currentRole ? currentRole.name : ""
                            
                            if (name === "") {
                                logger.logWarning("未选择角色")
                                return
                            }
                            
                            if (chatBgCropDialog.sourceImagePath === "") {
                                logger.logWarning("未选择聊天背景图片")
                                return
                            }
                            
                            // 转换 URL 为本地路径
                            var inputPath = chatBgCropDialog.sourceImagePath
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
                            var roleDir = characterManager.roleDir(name)
                            var pngPath = roleDir + "/background.png"
                            var binPath = roleDir + "/background.bin"
                            
                            console.log("roleDir:", roleDir)
                            console.log("pngPath:", pngPath)
                            console.log("binPath:", binPath)
                            console.log("offsetX:", chatBgCropDialog.offsetX, "offsetY:", chatBgCropDialog.offsetY)
                            console.log("scaleValue:", chatBgCropDialog.scaleValue)
                            logger.logInfo("开始处理聊天背景: " + pngPath)
                            
                            // 确保角色目录存在
                            characterManager.ensureRoleDir(name)
                            
                            // 验证 imageProcessor 是否存在
                            if (typeof imageProcessor === "undefined" || !imageProcessor) {
                                logger.logError("imageProcessor 未注册")
                                return
                            }
                            
                            if (typeof imageProcessor.cropRectangular !== "function") {
                                logger.logError("cropRectangular 函数不存在")
                                return
                            }
                            
                            // 调用 C++ 裁剪生成 PNG (280x171)
                            var success = imageProcessor.cropRectangular(
                                inputPath,
                                pngPath,
                                280,  // targetWidth
                                171,  // targetHeight
                                chatBgCropDialog.offsetX,
                                chatBgCropDialog.offsetY,
                                chatBgCropDialog.scaleValue,
                                280,  // previewWidth
                                171   // previewHeight
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
                                    "--type", "chatbg",
                                    "--input", pngPath,
                                    "--output", binPath
                                ])
                                
                                console.log("runScript 返回:", binSuccess)
                                
                                if (binSuccess) {
                                    logger.logInfo("聊天背景处理完成: " + binPath)
                                    characterManager.incrementChatBgVersion()
                                    chatBgCropDialog.close()
                                } else {
                                    logger.logError("BIN转换失败: " + pythonRunner.getOutput())
                                }
                            } else {
                                logger.logError("PNG裁剪失败")
                            }
                        } catch (e) {
                            console.error("聊天背景处理错误:", e)
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
                        chatBgCropDialog.close()
                    }
                }
            }
        }
    }
    
    FileDialog {
        id: chatBgFileDialog
        title: "选择聊天背景图片"
        nameFilters: ["PNG 图片 (*.png)"]
        onAccepted: {
            var filePath = selectedFile.toString()
            // 打开裁剪对话框而不是直接导入
            chatBgCropDialog.sourceImagePath = filePath
            chatBgCropDialog.open()
        }
    }
    
    FileDialog {
        id: voiceMaterialFileDialog
        title: "选择声音复刻素材"
        nameFilters: ["音频文件 (*.wav *.mp3 *.flac)"]
        onAccepted: {
            var name = currentRole ? currentRole.name : ""
            if (name !== "" && characterManager) {
                var filePath = selectedFile.toString()
                var result = characterManager.importVoiceMaterial(filePath, name)
                if (result !== "") {
                    logger.logInfo("声音素材导入成功: " + result)
                }
            } else {
                logger.logWarning("请先设置角色英文名")
            }
        }
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        Rectangle {
            Layout.preferredWidth: 120
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
                        text: "角色列表"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }
                }
                
                ListView {
                    id: roleListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    currentIndex: -1
                    model: characterManager ? characterManager.roleList : []
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 90
                        color: roleListView.currentIndex === index ? "#E6F7FF" : (itemMouseArea.containsMouse ? "#F0F0F0" : "transparent")
                        
                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                roleListView.currentIndex = index
                            }
                        }
                        
                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 5
                            anchors.rightMargin: 5
                            width: 20
                            height: 20
                            radius: 10
                            color: deleteMouseArea.containsMouse ? "#FF4D4F" : "#FF7875"
                            visible: itemMouseArea.containsMouse
                            z: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#FFFFFF"
                            }
                            
                            MouseArea {
                                id: deleteMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    pendingDeleteIndex = index
                                    deleteConfirmDialog.open()
                                }
                            }
                        }
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Rectangle {
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 60
                                radius: 30
                                color: "#CCCCCC"
                                clip: true
                                
                                Image {
                                    anchors.fill: parent
                                    source: {
                                        if (!characterManager) return ""
                                        var name = modelData.name
                                        if (name !== "") {
                                            var path = characterManager.avatarPath(name)
                                            if (path !== "") return "file:///" + path + "?v=" + characterManager.avatarVersion
                                        }
                                        return ""
                                    }
                                    fillMode: Image.PreserveAspectCrop
                                    visible: source !== ""
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name.charAt(0).toUpperCase()
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#FFFFFF"
                                    visible: parent.children[0].source === ""
                                }
                            }
                            
                            Text {
                                text: modelData.name
                                font.pixelSize: 14
                                color: roleListView.currentIndex === index ? "#1890FF" : "#333333"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#FFFFFF"
                    
                    Button {
                        anchors.centerIn: parent
                        text: "+ 添加角色"
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
                            addRoleDialog.open()
                        }
                    }
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFFFFF"
            
            property bool hasSelectedRole: roleListView.currentIndex >= 0 && currentRole !== null
            
            Text {
                anchors.centerIn: parent
                text: "请先创建一个角色"
                font.pixelSize: 16
                color: "#999999"
                visible: !parent.hasSelectedRole
            }
            
            ScrollView {
                anchors.fill: parent
                clip: true
                visible: parent.hasSelectedRole
                
                Item {
                    anchors.fill: parent
                    anchors.margins: 20
                    
                    // 点击空白区域时让 Item 获取焦点，使 TextField 失去焦点
                    MouseArea {
                        anchors.fill: parent
                        z: -1  // 放在最底层，不阻挡交互组件
                        onClicked: {
                            focus = true
                        }
                    }
                    
                    ColumnLayout {
                        id: leftColumn
                        width: parent.width * 0.45 - 15
                        height: parent.height
                        anchors.left: parent.left
                        spacing: 15
                        
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
                                        var name = currentRole ? currentRole.name : ""
                                        if (name !== "") {
                                            var path = characterManager.avatarPath(name)
                                            if (path !== "") return "file:///" + path + "?v=" + characterManager.avatarVersion
                                        }
                                        return ""
                                    }
                                    fillMode: Image.PreserveAspectCrop
                                    visible: source !== ""
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: currentRole ? currentRole.name.charAt(0).toUpperCase() : ""
                                    font.pixelSize: 28
                                    font.bold: true
                                    color: "#FFFFFF"
                                    visible: parent.children[0].source === ""
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (currentEnglishName() === "") {
                                            englishNameRequiredDialog.open()
                                        } else {
                                            avatarDialog.open()
                                        }
                                    }
                                }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                
                                Text {
                                    text: "角色名称:"
                                    font.pixelSize: 14
                                    color: "#333333"
                                }
                                
                                TextField {
                                    id: roleNameEdit
                                    Layout.fillWidth: true
                                    placeholderText: "输入角色名称"
                                    font.pixelSize: 14
                                    text: currentRole ? currentRole.name : ""
                                    onEditingFinished: {
                                        if (roleListView.currentIndex >= 0) {
                                            characterManager.updateRoleName(roleListView.currentIndex, text)
                                        }
                                    }
                                    onActiveFocusChanged: {
                                        if (!activeFocus && roleListView.currentIndex >= 0) {
                                            characterManager.updateRoleName(roleListView.currentIndex, text)
                                        }
                                    }
                                }
                                
                                Button {
                                    text: "更换头像"
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
                                        if (currentEnglishName() === "") {
                                            englishNameRequiredDialog.open()
                                        } else {
                                            avatarDialog.open()
                                        }
                                    }
                                }
                            }
                        }
                        
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 15
                            columnSpacing: 20
                            
                            Text {
                                text: "英文名(SD卡):"
                                font.pixelSize: 14
                                color: "#333333"
                            }
                            
                            TextField {
                                id: englishNameEdit
                                Layout.fillWidth: true
                                placeholderText: "输入8位以内英文名"
                                font.pixelSize: 14
                                maximumLength: 8
                                text: currentRole ? currentRole.englishName : ""
                                onEditingFinished: {
                                    if (roleListView.currentIndex >= 0) {
                                        characterManager.updateRoleEnglishName(roleListView.currentIndex, text)
                                    }
                                }
                                onActiveFocusChanged: {
                                    if (!activeFocus && roleListView.currentIndex >= 0) {
                                        characterManager.updateRoleEnglishName(roleListView.currentIndex, text)
                                    }
                                }
                            }
                        }
                        
                        Text {
                            text: "声音复刻"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333333"
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "模型选择:"
                                font.pixelSize: 14
                                color: "#333333"
                            }
                            
                            Text {
                                text: "cosyvoice-v3.5-plus"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#1890FF"
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                
                                Text {
                                    text: "素材文件:"
                                    font.pixelSize: 14
                                    color: "#333333"
                                }
                                
                                TextField {
                                    id: voiceMaterialEdit
                                    Layout.fillWidth: true
                                    placeholderText: "选择声音复刻素材文件"
                                    font.pixelSize: 14
                                    readOnly: true
                                    text: {
                                        if (!characterManager) return ""
                                        var name = currentRole ? currentRole.name : ""
                                        if (name !== "") {
                                            return characterManager.voiceMaterialPath(name)
                                        }
                                        return ""
                                    }
                                }
                                
                                Button {
                                    text: "选择文件"
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
                                
                                Button {
                                    text: "复刻"
                                    font.pixelSize: 12
                                    
                                    background: Rectangle {
                                        color: parent.hovered ? "#FF7875" : "#FF4D4F"
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
                                        console.log("开始声音复刻")
                                    }
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                
                                Text {
                                    text: "试听文本:"
                                    font.pixelSize: 14
                                    color: "#333333"
                                }
                                
                                TextField {
                                    id: testTextEdit
                                    Layout.fillWidth: true
                                    placeholderText: "输入试听文本"
                                    font.pixelSize: 14
                                }
                                
                                Button {
                                    text: "合成试听"
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
                                        console.log("合成试听")
                                    }
                                }
                            }
                        }
                        
                        Text {
                            text: "智能体配置"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333333"
                        }
                        
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 15
                            columnSpacing: 20
                            
                            Text {
                                text: "智能体地址:"
                                font.pixelSize: 14
                                color: "#333333"
                            }
                            
                            TextField {
                                id: agentUrlEdit
                                Layout.fillWidth: true
                                placeholderText: "输入智能体API地址"
                                font.pixelSize: 14
                                text: currentRole ? currentRole.agentUrl : ""
                                onEditingFinished: {
                                    if (roleListView.currentIndex >= 0) {
                                        characterManager.updateRoleAgentUrl(roleListView.currentIndex, text)
                                    }
                                }
                                onActiveFocusChanged: {
                                    if (!activeFocus && roleListView.currentIndex >= 0) {
                                        characterManager.updateRoleAgentUrl(roleListView.currentIndex, text)
                                    }
                                }
                            }
                            
                            Text {
                                text: "智能体ID:"
                                font.pixelSize: 14
                                color: "#333333"
                            }
                            
                            TextField {
                                id: agentIdEdit
                                Layout.fillWidth: true
                                placeholderText: "输入智能体ID"
                                font.pixelSize: 14
                                text: currentRole ? currentRole.agentId : ""
                                onEditingFinished: {
                                    if (roleListView.currentIndex >= 0) {
                                        characterManager.updateRoleAgentId(roleListView.currentIndex, text)
                                    }
                                }
                                onActiveFocusChanged: {
                                    if (!activeFocus && roleListView.currentIndex >= 0) {
                                        characterManager.updateRoleAgentId(roleListView.currentIndex, text)
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: "#F5F5F5"
                            radius: 4
                            
                            Button {
                                anchors.centerIn: parent
                                text: "智能体配置与测试"
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
                                    console.log("打开智能体配置与测试")
                                }
                            }
                        }
                        
                        Text {
                            text: "聊天背景"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333333"
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.min(171, parent.width * 0.61)
                                Layout.maximumWidth: 280
                                color: "#F0F0F0"
                                border.color: "#D9D9D9"
                                border.width: 1
                                radius: 4
                                clip: true
                                
                                Image {
                                    anchors.fill: parent
                                    source: {
                                        if (!characterManager) return ""
                                        var name = currentRole ? currentRole.name : ""
                                        if (name !== "") {
                                            var path = characterManager.chatBgPath(name)
                                            if (path !== "") return "file:///" + path + "?v=" + characterManager.chatBgVersion
                                        }
                                        return ""
                                    }
                                    fillMode: Image.PreserveAspectCrop
                                    visible: source !== ""
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "未设置背景"
                                    font.pixelSize: 14
                                    color: "#999999"
                                    visible: {
                                        if (!characterManager) return true
                                        var name = currentRole ? currentRole.name : ""
                                        if (name === "") return true
                                        var path = characterManager.chatBgPath(name)
                                        return path === ""
                                    }
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                
                                Button {
                                    text: "载入背景"
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
                                        chatBgFileDialog.open()
                                    }
                                }
                                
                                Button {
                                    text: "清除背景"
                                    font.pixelSize: 12
                                    
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
                                        var name = currentRole ? currentRole.name : ""
                                        if (name !== "") {
                                            characterManager.removeChatBg(name)
                                        }
                                    }
                                }
                                
                                Text {
                                    text: "PNG 280×171"
                                    font.pixelSize: 11
                                    color: "#999999"
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: "#F6FFED"
                            radius: 4
                            
                            Button {
                                anchors.centerIn: parent
                                text: "生成NFC信息"
                                font.pixelSize: 14
                                
                                background: Rectangle {
                                    color: parent.hovered ? "#73D13D" : "#52C41A"
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
                                    nfcGenerated = true
                                    if (currentRole)
                                        nfcResult = "NFC_INFO:role=" + currentRole.name + ",id=" + currentRole.id
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            color: "#FAFAFA"
                            border.color: "#D9D9D9"
                            border.width: 1
                            radius: 4
                            
                            TextArea {
                                id: nfcResultEdit
                                anchors.fill: parent
                                anchors.margins: 8
                                placeholderText: "NFC信息将在此显示..."
                                font.pixelSize: 14
                                wrapMode: TextArea.Wrap
                                readOnly: true
                                text: nfcResult
                                background: Rectangle { color: "transparent" }
                            }
                        }
                        
                        Button {
                            text: "复制NFC信息"
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
                                nfcResultEdit.selectAll()
                                nfcResultEdit.copy()
                                nfcResultEdit.deselect()
                            }
                        }
                    }
                    
                    ColumnLayout {
                        id: rightColumn
                        width: parent.width * 0.55 - 15
                        height: parent.height
                        anchors.left: leftColumn.right
                        anchors.leftMargin: 30
                        spacing: 15
                        
                        Text {
                            text: "参考提示词"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333333"
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 120
                            color: "#FAFAFA"
                            border.color: "#D9D9D9"
                            border.width: 1
                            radius: 4
                            
                            TextArea {
                                id: promptEdit
                                anchors.fill: parent
                                anchors.margins: 8
                                placeholderText: "输入参考提示词..."
                                font.pixelSize: 14
                                wrapMode: TextArea.Wrap
                                text: currentRole ? currentRole.prompt : ""
                                background: Rectangle { color: "transparent" }
                                
                                onEditingFinished: {
                                    if (roleListView.currentIndex >= 0) {
                                        characterManager.updateRolePrompt(roleListView.currentIndex, text)
                                    }
                                }
                                onActiveFocusChanged: {
                                    if (!activeFocus && roleListView.currentIndex >= 0) {
                                        characterManager.updateRolePrompt(roleListView.currentIndex, text)
                                    }
                                }
                            }
                        }
                        
                        Button {
                            text: "复制提示词"
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
                                promptEdit.selectAll()
                                promptEdit.copy()
                                promptEdit.deselect()
                            }
                        }
                    }
                }
            }
        }
    }
}
