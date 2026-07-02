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
            text: "账号配置"
            font.pixelSize: 18
            font.bold: true
            color: "#333333"
        }
        
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 10
            columnSpacing: 20
            
            Text {
                text: "API密钥:"
                font.pixelSize: 14
                color: "#666666"
            }
            
            TextField {
                Layout.fillWidth: true
                placeholderText: "请输入API密钥"
                font.pixelSize: 14
            }
            
            Text {
                text: "服务商:"
                font.pixelSize: 14
                color: "#666666"
            }
            
            ComboBox {
                Layout.fillWidth: true
                model: ["阿里云", "腾讯云", "百度智能云"]
                font.pixelSize: 14
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
        
        RowLayout {
            Layout.fillWidth: true
            
            Button {
                text: "保存"
                font.pixelSize: 14
            }
            
            Button {
                text: "测试连接"
                font.pixelSize: 14
            }
        }
    }
}