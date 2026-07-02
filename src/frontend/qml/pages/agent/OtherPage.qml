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
            text: "其他设置"
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
                text: "语言:"
                font.pixelSize: 14
                color: "#666666"
            }
            
            ComboBox {
                Layout.fillWidth: true
                model: ["中文", "英文"]
                font.pixelSize: 14
            }
            
            Text {
                text: "响应超时:"
                font.pixelSize: 14
                color: "#666666"
            }
            
            SpinBox {
                Layout.fillWidth: true
                value: 30
                from: 10
                to: 120
                font.pixelSize: 14
            }
            
            Text {
                text: "日志级别:"
                font.pixelSize: 14
                color: "#666666"
            }
            
            ComboBox {
                Layout.fillWidth: true
                model: ["DEBUG", "INFO", "WARNING", "ERROR"]
                font.pixelSize: 14
            }
            
            Text {
                text: "自动保存:"
                font.pixelSize: 14
                color: "#666666"
            }
            
            CheckBox {
                checked: true
                font.pixelSize: 14
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
    }
}