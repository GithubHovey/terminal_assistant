import QtQuick
import QtQuick.Controls

Label {
    id: root
    font.family: "Consolas"
    font.pixelSize: 12
    color: "#666666"
    
    property string fullLog: ""
    property alias logText: root.fullLog
    
    function appendLog(message) {
        var timestamp = Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss");
        root.fullLog += "[" + timestamp + "] " + message + "\n";
        updateDisplayText();
    }
    
    function clearLog() {
        root.fullLog = "";
        root.text = "";
    }
    
    function updateDisplayText() {
        var lastLine = "";
        var lines = root.fullLog.split("\n");
        for (var i = lines.length - 1; i >= 0; i--) {
            if (lines[i].trim() !== "") {
                lastLine = lines[i];
                break;
            }
        }
        if (lastLine.length > 100) {
            root.text = lastLine.substring(0, 100) + "...";
        } else {
            root.text = lastLine;
        }
    }
    
    ToolTip.visible: mouseArea.containsMouse && root.fullLog !== ""
    ToolTip.text: root.fullLog
    ToolTip.delay: 500
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}