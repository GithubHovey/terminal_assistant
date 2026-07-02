import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#F5F5F5"
    
    Label {
        anchors.centerIn: parent
        text: qsTr("基础配置页面")
        font.pixelSize: 24
        color: "#666666"
    }
}