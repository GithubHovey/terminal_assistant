import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "#FFFFFF"
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20
        
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