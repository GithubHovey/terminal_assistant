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
            text: "知识库管理"
            font.pixelSize: 18
            font.bold: true
            color: "#333333"
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            TextField {
                Layout.fillWidth: true
                placeholderText: "搜索知识库"
                font.pixelSize: 14
            }
            
            Button {
                text: "新建"
                font.pixelSize: 14
            }
            
            Button {
                text: "导入"
                font.pixelSize: 14
            }
        }
        
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            model: ListModel {
                ListElement { name: "设备手册"; size: "2.5MB"; updateTime: "2026-07-01" }
                ListElement { name: "常见问题"; size: "1.2MB"; updateTime: "2026-06-28" }
            }
            
            delegate: Rectangle {
                width: parent.width
                height: 60
                color: mouseArea.containsMouse ? "#E6F7FF" : "#FAFAFA"
                border.color: "#E0E0E0"
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: model.name
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                        }
                        
                        Text {
                            text: model.size + " | " + model.updateTime
                            font.pixelSize: 12
                            color: "#999999"
                        }
                    }
                    
                    Button {
                        text: "编辑"
                        font.pixelSize: 12
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