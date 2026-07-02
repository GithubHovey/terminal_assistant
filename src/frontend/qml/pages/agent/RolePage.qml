import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#FFFFFF"
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "角色管理"
                font.pixelSize: 18
                font.bold: true
                color: "#333333"
            }
            
            Item {
                Layout.fillWidth: true
            }
            
            Button {
                text: "新建角色"
                font.pixelSize: 14
            }
        }
        
        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 200
            cellHeight: 180
            clip: true
            
            model: ListModel {
                ListElement { name: "助手小蓝"; roleId: "1001" }
                ListElement { name: "技术专家"; roleId: "1002" }
                ListElement { name: "客服小美"; roleId: "1003" }
            }
            
            delegate: Rectangle {
                width: 180
                height: 160
                color: mouseArea.containsMouse ? "#E6F7FF" : "#FFFFFF"
                border.color: "#E0E0E0"
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    
                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        Layout.alignment: Qt.AlignHCenter
                        color: "#1890FF"
                        radius: 30
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🎭"
                            font.pixelSize: 24
                            color: "#FFFFFF"
                        }
                    }
                    
                    Text {
                        text: model.name
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "ID: " + model.roleId
                        font.pixelSize: 12
                        color: "#999999"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5
                        
                        Button {
                            text: "编辑"
                            font.pixelSize: 12
                        }
                        
                        Button {
                            text: "删除"
                            font.pixelSize: 12
                        }
                    }
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }
}