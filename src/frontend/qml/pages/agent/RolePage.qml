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
        if (currentRole && currentRole.englishName)
            return currentRole.englishName.trim()
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
            var name = currentRole ? currentRole.name : ""
            if (name !== "" && characterManager) {
                var filePath = selectedFile.toString()
                var result = characterManager.importAvatar(filePath, name)
                if (result !== "") {
                    logger.logInfo("头像导入成功: " + result)
                }
            } else {
                logger.logWarning("请先选择角色")
            }
        }
    }
    
    FileDialog {
        id: chatBgFileDialog
        title: "选择聊天背景图片"
        nameFilters: ["PNG 图片 (*.png)"]
        onAccepted: {
            var name = currentRole ? currentRole.name : ""
            if (name !== "" && characterManager) {
                var filePath = selectedFile.toString()
                var result = characterManager.importChatBg(filePath, name)
                if (result !== "") {
                    logger.logInfo("聊天背景导入成功: " + result)
                }
            } else {
                logger.logWarning("请先选择角色")
            }
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
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name.charAt(0).toUpperCase()
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#FFFFFF"
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
                                            if (path !== "") return "file:///" + path
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
                                        avatarDialog.open()
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
                                        avatarDialog.open()
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
                                placeholderText: "输入大写英文名"
                                font.pixelSize: 14
                                maximumLength: 8
                                text: currentRole ? currentRole.englishName : ""
                                onEditingFinished: {
                                    if (roleListView.currentIndex >= 0) {
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
                                            if (path !== "") return "file:///" + path
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
