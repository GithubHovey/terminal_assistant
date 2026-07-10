import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#F5F5F5"
    
    Label {
        anchors.centerIn: parent
        text: qsTr("开发中")
        font.pixelSize: 24
        color: "#666666"
    }
}