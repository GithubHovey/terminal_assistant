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
            
            Text {
                anchors.centerIn: parent
                text: "角色详情编辑区"
                font.pixelSize: 16
                color: "#999999"
            }
        }
    }
}