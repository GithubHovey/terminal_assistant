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
                text: "阿里云"
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
        
        Item {
            Layout.fillHeight: true
        }
    }
}