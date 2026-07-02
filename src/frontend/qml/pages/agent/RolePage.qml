import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    color: "#FFFFFF"
    
    property string newRoleName: ""
    property int deleteIndex: -1
    
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
                onTextChanged: newRoleName = text
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
                        if (newRoleName.trim() !== "") {
                            roleListView.model.append({ roleName: newRoleName.trim(), canDelete: true })
                            roleNameInput.text = ""
                            newRoleName = ""
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
                        newRoleName = ""
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
                text: "确定要删除该角色吗？"
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
                        if (deleteIndex >= 0) {
                            roleListView.model.remove(deleteIndex)
                            deleteIndex = -1
                            deleteConfirmDialog.close()
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
                        deleteIndex = -1
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
                    console.log("选择头像图片")
                    avatarDialog.close()
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
                    
                    model: ListModel {
                        ListElement { roleName: "user"; canDelete: false }
                    }
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 90
                        color: roleListView.currentIndex === index ? "#E6F7FF" : (itemMouseArea.containsMouse ? "#F0F0F0" : "transparent")
                        
                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 5
                            anchors.rightMargin: 5
                            width: 20
                            height: 20
                            radius: 10
                            color: deleteMouseArea.containsMouse ? "#FF4D4F" : "#FF7875"
                            visible: canDelete && itemMouseArea.containsMouse
                            
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
                                    deleteIndex = index
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
                                    text: roleName.charAt(0).toUpperCase()
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#FFFFFF"
                                }
                            }
                            
                            Text {
                                text: roleName
                                font.pixelSize: 14
                                color: roleListView.currentIndex === index ? "#1890FF" : "#333333"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        
                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                roleListView.currentIndex = index
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
            
            ScrollView {
                anchors.fill: parent
                clip: true
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 80
                            radius: 40
                            color: "#CCCCCC"
                            
                            Text {
                                anchors.centerIn: parent
                                text: roleListView.currentItem ? roleListView.model.get(roleListView.currentIndex).roleName.charAt(0).toUpperCase() : "U"
                                font.pixelSize: 28
                                font.bold: true
                                color: "#FFFFFF"
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
                                text: roleListView.currentItem ? roleListView.model.get(roleListView.currentIndex).roleName : ""
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
                        }
                    }
                    
                    Text {
                        text: "声音复刻"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
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
                                    console.log("选择声音素材文件")
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
                        text: "参考提示词"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }
                    
                    TextArea {
                        id: promptEdit
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 120
                        placeholderText: "输入参考提示词..."
                        font.pixelSize: 14
                        wrapMode: TextArea.Wrap
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
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
                        
                        Item {
                            Layout.fillWidth: true
                        }
                        
                        Button {
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
                                console.log("生成NFC信息")
                            }
                        }
                    }
                }
            }
        }
    }
}