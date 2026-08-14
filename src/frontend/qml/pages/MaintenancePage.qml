import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: root
    color: "#F5F5F5"

    property string firmwarePath: ""
    property string detectedChip: ""
    property bool shuttingDown: false
    Component.onDestruction: shuttingDown = true

    Component.onCompleted: {
        espFlasher.scanPorts()
    }

    Connections {
        target: espFlasher
        function onSerialDataReceived(data) {
            logArea.text += data
            logFlickable.contentY = logArea.height - logFlickable.height
        }
        function onLogOutput(line) {
            logArea.text += line + "\n"
            logFlickable.contentY = logArea.height - logFlickable.height
        }
        function onOperationFinished(success, message) {
            if (!success) {
                errorLabel.text = message
                errorLabel.visible = true
            }
        }
        function onErrorOccurred(error) {
            errorLabel.text = error
            errorLabel.visible = true
        }
        function onChipDetected(info) {
            detectedChip = info
        }
    }

    FileDialog {
        id: firmwareDialog
        title: "选择固件文件"
        nameFilters: ["Binary files (*.bin)", "All files (*)"]
        onAccepted: {
            firmwarePath = selectedFile.toString().replace("file:///", "")
            firmwareInput.text = firmwarePath
        }
    }

    FileDialog {
        id: exportLogDialog
        title: "导出日志到文件"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Text files (*.txt)", "Log files (*.log)", "All files (*)"]
        currentFile: "file:///" + "maintenance_log_" + new Date().toISOString().slice(0, 10).replace(/-/g, "") + ".txt"
        onAccepted: {
            var filePath = selectedFile.toString().replace("file:///", "")
            if (maintenanceManager.exportLogs(logArea.text, filePath)) {
                logger.logInfo("日志已导出到: " + filePath)
            }
        }
    }

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        spacing: 12
        anchors.margins: 16

        Flickable {
            id: topFlickable
            Layout.fillWidth: true
            Layout.preferredHeight: topColumn.implicitHeight
            contentHeight: topColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: topColumn
                width: parent.width
                spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: serialCard.height
                radius: 8
                color: "#FFFFFF"

                ColumnLayout {
                    id: serialCard
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "串口连接"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333333"
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "刷新"
                            font.pixelSize: 13
                            enabled: !shuttingDown && !espFlasher.running
                            onClicked: espFlasher.scanPorts()

                            background: Rectangle {
                                color: parent.hovered ? "#E6F7FF" : "#F0F0F0"
                                border.width: 1
                                border.color: "#D9D9D9"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "#333333"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "串口"
                                font.pixelSize: 12
                                color: "#999999"
                            }
                            ComboBox {
                                id: portCombo
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                enabled: !shuttingDown && !espFlasher.running && !espFlasher.monitoring
                                model: shuttingDown ? [] : espFlasher.availablePorts
                                textRole: ""
                                delegate: ItemDelegate {
                                    width: portCombo.width
                                    contentItem: Text {
                                        text: modelData.description + " (" + modelData.name + ")"
                                        font.pixelSize: 13
                                        color: "#333333"
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    highlighted: portCombo.highlightedIndex === index
                                }
                                contentItem: Text {
                                    text: portCombo.currentIndex >= 0 && !shuttingDown
                                          ? espFlasher.availablePorts[portCombo.currentIndex].description
                                          : "选择串口"
                                    font.pixelSize: 13
                                    color: "#333333"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                                background: Rectangle {
                                    color: "#FFFFFF"
                                    border.width: 1
                                    border.color: "#D9D9D9"
                                    radius: 4
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "波特率"
                                font.pixelSize: 12
                                color: "#999999"
                            }
                            ComboBox {
                                id: baudCombo
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                enabled: !shuttingDown && !espFlasher.running && !espFlasher.monitoring
                                model: ["9600", "115200", "230400", "460800", "921600"]
                                currentIndex: 1
                                contentItem: Text {
                                    text: baudCombo.displayText
                                    font.pixelSize: 13
                                    color: "#333333"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                                background: Rectangle {
                                    color: "#FFFFFF"
                                    border.width: 1
                                    border.color: "#D9D9D9"
                                    radius: 4
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "芯片类型"
                                font.pixelSize: 12
                                color: "#999999"
                            }
                            ComboBox {
                                id: chipCombo
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                enabled: !shuttingDown && !espFlasher.running
                                model: ["esp32", "esp32s2", "esp32s3", "esp32c3", "esp32c6", "esp32h2", "esp8266"]
                                contentItem: Text {
                                    text: chipCombo.displayText
                                    font.pixelSize: 13
                                    color: "#333333"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                                background: Rectangle {
                                    color: "#FFFFFF"
                                    border.width: 1
                                    border.color: "#D9D9D9"
                                    radius: 4
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Button {
                            text: !shuttingDown && espFlasher.monitoring ? "断开监视" : "连接监视"
                            font.pixelSize: 13
                            font.bold: true
                            enabled: !shuttingDown && portCombo.currentIndex >= 0 && !espFlasher.running
                            Layout.preferredHeight: 36

                            background: Rectangle {
                                color: {
                                    if (!parent.enabled) return "#F5F5F5"
                                    if (!shuttingDown && espFlasher.monitoring)
                                        return parent.pressed ? "#CF1322" : (parent.hovered ? "#FF7875" : "#FF4D4F")
                                    else
                                        return parent.pressed ? "#096DD9" : (parent.hovered ? "#40A9FF" : "#1890FF")
                                }
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: parent.enabled ? "#FFFFFF" : "#BFBFBF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                errorLabel.visible = false
                                if (espFlasher.monitoring) {
                                    espFlasher.disconnectMonitor()
                                } else {
                                    var portInfo = espFlasher.availablePorts[portCombo.currentIndex]
                                    var portName = portInfo.name
                                    var baud = parseInt(baudCombo.currentText)
                                    if (!espFlasher.connectMonitor(portName, baud)) {
                                        // error signal will show
                                    }
                                }
                            }
                        }

                        Button {
                            text: "读取芯片信息"
                            font.pixelSize: 13
                            enabled: !shuttingDown && portCombo.currentIndex >= 0 && !espFlasher.running && !espFlasher.monitoring
                            Layout.preferredHeight: 36

                            background: Rectangle {
                                color: parent.hovered ? "#E6F7FF" : "#FFFFFF"
                                border.width: 1
                                border.color: "#D9D9D9"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: parent.enabled ? "#333333" : "#BFBFBF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                errorLabel.visible = false
                                var portInfo = espFlasher.availablePorts[portCombo.currentIndex]
                                espFlasher.readChipInfo(portInfo.name, chipCombo.currentText, parseInt(baudCombo.currentText))
                            }
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            spacing: 6
                            visible: !shuttingDown && (espFlasher.monitoring || detectedChip.length > 0)
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: !shuttingDown && espFlasher.monitoring ? "#52C41A" : "#D9D9D9"
                            }
                            Text {
                                text: detectedChip.length > 0 ? detectedChip : (!shuttingDown && espFlasher.monitoring ? "监视中" : "")
                                font.pixelSize: 12
                                color: "#666666"
                                elide: Text.ElideRight
                                Layout.maximumWidth: 300
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: flashCard.height
                radius: 8
                color: "#FFFFFF"

                ColumnLayout {
                    id: flashCard
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: "固件烧录"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        TextField {
                            id: firmwareInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            placeholderText: "选择固件文件..."
                            font.pixelSize: 13
                            readOnly: true
                            text: ""
                            background: Rectangle {
                                color: "#FAFAFA"
                                border.width: 1
                                border.color: "#D9D9D9"
                                radius: 4
                            }
                        }

                        Button {
                            text: "浏览"
                            font.pixelSize: 13
                            enabled: !shuttingDown && !espFlasher.running
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 70

                            background: Rectangle {
                                color: parent.hovered ? "#E6F7FF" : "#F0F0F0"
                                border.width: 1
                                border.color: "#D9D9D9"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "#333333"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: firmwareDialog.open()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "偏移地址"
                                font.pixelSize: 12
                                color: "#999999"
                            }
                            TextField {
                                id: offsetInput
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                text: "0x10000"
                                font.pixelSize: 13
                                enabled: !shuttingDown && !espFlasher.running
                                background: Rectangle {
                                    color: "#FFFFFF"
                                    border.width: 1
                                    border.color: "#D9D9D9"
                                    radius: 4
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "Flash模式"
                                font.pixelSize: 12
                                color: "#999999"
                            }
                            ComboBox {
                                id: flashModeCombo
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                enabled: !shuttingDown && !espFlasher.running
                                model: ["dio", "qio", "dout", "qout"]
                                contentItem: Text {
                                    text: flashModeCombo.displayText
                                    font.pixelSize: 13
                                    color: "#333333"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                                background: Rectangle {
                                    color: "#FFFFFF"
                                    border.width: 1
                                    border.color: "#D9D9D9"
                                    radius: 4
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "Flash大小"
                                font.pixelSize: 12
                                color: "#999999"
                            }
                            ComboBox {
                                id: flashSizeCombo
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                enabled: !shuttingDown && !espFlasher.running
                                model: ["4MB", "2MB", "8MB", "16MB", "1MB"]
                                contentItem: Text {
                                    text: flashSizeCombo.displayText
                                    font.pixelSize: 13
                                    color: "#333333"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                                background: Rectangle {
                                    color: "#FFFFFF"
                                    border.width: 1
                                    border.color: "#D9D9D9"
                                    radius: 4
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Button {
                            text: !shuttingDown && espFlasher.running ? "中止" : "烧录固件"
                            font.pixelSize: 13
                            font.bold: true
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 120
                            enabled: !shuttingDown && (espFlasher.running || (portCombo.currentIndex >= 0 && firmwarePath.length > 0))

                            background: Rectangle {
                                color: {
                                    if (!parent.enabled) return "#F5F5F5"
                                    if (!shuttingDown && espFlasher.running)
                                        return parent.pressed ? "#CF1322" : (parent.hovered ? "#FF7875" : "#FF4D4F")
                                    return parent.pressed ? "#096DD9" : (parent.hovered ? "#40A9FF" : "#1890FF")
                                }
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: parent.enabled ? "#FFFFFF" : "#BFBFBF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                errorLabel.visible = false
                                if (espFlasher.running) {
                                    espFlasher.abort()
                                } else {
                                    var portInfo = espFlasher.availablePorts[portCombo.currentIndex]
                                    espFlasher.flashFirmware(
                                        portInfo.name,
                                        firmwarePath,
                                        offsetInput.text,
                                        chipCombo.currentText,
                                        parseInt(baudCombo.currentText),
                                        flashModeCombo.currentText,
                                        flashSizeCombo.currentText
                                    )
                                }
                            }
                        }

                        Button {
                            text: "擦除Flash"
                            font.pixelSize: 13
                            font.bold: true
                            enabled: !shuttingDown && portCombo.currentIndex >= 0 && !espFlasher.running && !espFlasher.monitoring
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 120

                            background: Rectangle {
                                color: {
                                    if (!parent.enabled) return "#F5F5F5"
                                    return parent.pressed ? "#CF1322" : (parent.hovered ? "#FF7875" : "#FF4D4F")
                                }
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: parent.enabled ? "#FFFFFF" : "#BFBFBF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                errorLabel.visible = false
                                confirmDialog.open()
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    Text {
                        id: errorLabel
                        visible: false
                        Layout.fillWidth: true
                        font.pixelSize: 13
                        color: "#FF4D4F"
                        wrapMode: Text.Wrap
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: 8
                color: "#FFFFFF"
                visible: !shuttingDown && espFlasher.running

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    ProgressBar {
                        id: progressBar
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        from: 0
                        to: 100
                        value: !shuttingDown ? espFlasher.progress : 0

                        background: Rectangle {
                            color: "#F0F0F0"
                            radius: 4
                        }
                        contentItem: Item {
                            Rectangle {
                                width: progressBar.visualPosition * parent.width
                                height: parent.height
                                color: "#1890FF"
                                radius: 4
                            }
                        }
                    }

                    Text {
                        text: (!shuttingDown ? espFlasher.progress : 0) + "%"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#1890FF"
                        Layout.preferredWidth: 40
                    }

                    Text {
                        text: !shuttingDown ? espFlasher.currentOperation : ""
                        font.pixelSize: 13
                        color: "#666666"
                    }
                }
            }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 150
                radius: 8
                color: "#FFFFFF"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "串口日志 / 操作日志"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333333"
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "清屏"
                            font.pixelSize: 13
                            Layout.preferredHeight: 28
                            Layout.preferredWidth: 60

                            background: Rectangle {
                                color: parent.hovered ? "#E6F7FF" : "#F0F0F0"
                                border.width: 1
                                border.color: "#D9D9D9"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "#333333"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: logArea.text = ""
                        }

                        Button {
                            text: "导出日志"
                            font.pixelSize: 13
                            Layout.preferredHeight: 28
                            Layout.preferredWidth: 80
                            enabled: logArea.text.length > 0

                            background: Rectangle {
                                color: {
                                    if (!parent.enabled) return "#F5F5F5"
                                    return parent.hovered ? "#E6F7FF" : "#F0F0F0"
                                }
                                border.width: 1
                                border.color: "#D9D9D9"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: parent.enabled ? "#333333" : "#BFBFBF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: exportLogDialog.open()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 4
                        color: "#FAFAFA"
                        border.width: 1
                        border.color: "#E8E8E8"

                        Flickable {
                            id: logFlickable
                            anchors.fill: parent
                            anchors.margins: 8
                            contentHeight: logArea.implicitHeight
                            clip: true

                            TextArea {
                                id: logArea
                                width: logFlickable.width
                                readOnly: true
                                wrapMode: Text.Wrap
                                textFormat: Text.PlainText
                                font.family: "Consolas"
                                font.pixelSize: 12
                                color: "#333333"
                                selectByMouse: true
                                background: Rectangle {
                                    color: "transparent"
                                }
                            }
                        }

                        ScrollBar {
                            parent: logFlickable.parent
                            anchors.right: parent.right
                            policy: ScrollBar.AsNeeded
                            orientation: Qt.Vertical
                        }
                    }
                }
            }
    }

    Dialog {
        id: confirmDialog
        title: "确认擦除"
        modal: true
        anchors.centerIn: parent

        ColumnLayout {
            spacing: 12

            Text {
                text: "确定要擦除整个Flash吗？此操作不可恢复！"
                font.pixelSize: 14
                color: "#333333"
                wrapMode: Text.Wrap
                Layout.maximumWidth: 300
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Button {
                    text: "取消"
                    font.pixelSize: 13
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 80

                    background: Rectangle {
                        color: parent.hovered ? "#E0E0E0" : "#FFFFFF"
                        border.width: 1
                        border.color: "#D9D9D9"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#333333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: confirmDialog.close()
                }

                Button {
                    text: "确认擦除"
                    font.pixelSize: 13
                    font.bold: true
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 100

                    background: Rectangle {
                        color: parent.pressed ? "#CF1322" : (parent.hovered ? "#FF7875" : "#FF4D4F")
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
                        confirmDialog.close()
                        var portInfo = espFlasher.availablePorts[portCombo.currentIndex]
                        espFlasher.eraseFlash(portInfo.name, chipCombo.currentText, parseInt(baudCombo.currentText))
                    }
                }
            }
        }
    }
}
