import QtQuick
import QtQuick.Controls

Button {
    id: control
    implicitWidth: 100
    implicitHeight: 40
    
    background: Rectangle {
        color: control.pressed ? "#096DD9" : (control.hovered ? "#40A9FF" : "#1890FF")
        radius: 8
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
    
    contentItem: Text {
        text: control.text
        font.pixelSize: 14
        font.bold: true
        color: "#FFFFFF"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}