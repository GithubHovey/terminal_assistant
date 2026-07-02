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
        
        Text {
            text: "热词库管理"
            font.pixelSize: 18
            font.bold: true
            color: "#333333"
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            TextField {
                Layout.fillWidth: true
                placeholderText: "输入热词"
                font.pixelSize: 14
            }
            
            Button {
                text: "添加"
                font.pixelSize: 14
            }
            
            Button {
                text: "导入"
                font.pixelSize: 14
            }
            
            Button {
                text: "导出"
                font.pixelSize: 14
            }
        }
        
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            model: ListModel {
                ListElement { word: "终端设备"; category: "技术" }
                ListElement { word: "深空通信"; category: "业务" }
                ListElement { word: "智能助手"; category: "产品" }
            }
            
            delegate: Rectangle {
                width: parent.width
                height: 50
                color: mouseArea.containsMouse ? "#E6F7FF" : "#FAFAFA"
                border.color: "#E0E0E0"
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    
                    Text {
                        text: model.word
                        font.pixelSize: 14
                        color: "#333333"
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: model.category
                        font.pixelSize: 12
                        color: "#999999"
                    }
                    
                    Button {
                        text: "删除"
                        font.pixelSize: 12
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