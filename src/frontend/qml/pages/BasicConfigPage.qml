import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: root
    color: "#FFFFFF"
    property string previewSource: basicConfig ? "file:///" + basicConfig.bootlogoPath.replace(/\\/g, "/") + "?t=" + Date.now() : ""

    Dialog {
        id: cropDialog
        title: "调整开机动画"
        modal: true
        anchors.centerIn: parent
        width: 400
        height: 440

        property string sourcePath: ""
        property real offsetX: 0
        property real offsetY: 0
        property real scaleValue: 1.0
        property bool speedUp: true

        onOpened: {
            offsetX = 0
            offsetY = 0
            scaleValue = 1.0
            speedUp = true
            speedCheckBox.checked = true
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            Item {
                Layout.preferredWidth: 320
                Layout.preferredHeight: 240
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    anchors.fill: parent
                    color: "#000000"
                    clip: true

                    AnimatedImage {
                        id: cropImage
                        width: sourceSize.width * cropDialog.scaleValue
                        height: sourceSize.height * cropDialog.scaleValue
                        x: (320 - width) / 2 + cropDialog.offsetX
                        y: (240 - height) / 2 + cropDialog.offsetY
                        source: cropDialog.sourcePath
                        playing: true
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "#1890FF"
                    border.width: 2
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.OpenHandCursor
                    property point lastPos
                    property bool dragging: false

                    onPressed: {
                        dragging = true
                        lastPos = Qt.point(mouseX, mouseY)
                        cursorShape = Qt.ClosedHandCursor
                    }

                    onPositionChanged: {
                        if (dragging) {
                            cropDialog.offsetX += mouseX - lastPos.x
                            cropDialog.offsetY += mouseY - lastPos.y
                            lastPos = Qt.point(mouseX, mouseY)
                        }
                    }

                    onReleased: {
                        dragging = false
                        cursorShape = Qt.OpenHandCursor
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "缩放:"
                    font.pixelSize: 12
                    color: "#666666"
                }

                Slider {
                    id: scaleSlider
                    Layout.fillWidth: true
                    from: 0.1
                    to: 3.0
                    value: 1.0
                    stepSize: 0.1

                    onValueChanged: cropDialog.scaleValue = value
                }

                Text {
                    text: scaleSlider.value.toFixed(1)
                    font.pixelSize: 12
                    color: "#666666"
                    Layout.preferredWidth: 30
                }
            }

            CheckBox {
                id: speedCheckBox
                text: "2倍速播放（适配终端播放速度）"
                checked: true
                onCheckedChanged: cropDialog.speedUp = checked
            }

            Text {
                text: "拖拽移动画面，滑块调整缩放"
                font.pixelSize: 11
                color: "#999999"
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                Button {
                    text: "确定"
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
                        if (basicConfig && cropDialog.sourcePath !== "") {
                            var path = cropDialog.sourcePath
                            if (path.startsWith("file:///")) {
                                path = path.substring(8)
                            }
                            if (basicConfig.replaceBootlogo(path, cropDialog.offsetX, cropDialog.offsetY, cropDialog.scaleValue, cropDialog.speedUp)) {
                                root.previewSource = "file:///" + basicConfig.bootlogoPath.replace(/\\/g, "/") + "?t=" + Date.now()
                                cropDialog.close()
                            }
                        }
                    }
                }

                Button {
                    text: "取消"
                    font.pixelSize: 14

                    background: Rectangle {
                        color: parent.hovered ? "#E0E0E0" : "#FFFFFF"
                        border.color: "#D9D9D9"
                        border.width: 1
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#333333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: cropDialog.close()
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "选择开机动画GIF"
        fileMode: FileDialog.OpenFile
        nameFilters: ["GIF 文件 (*.gif)"]
        onAccepted: {
            cropDialog.sourcePath = selectedFile.toString()
            cropDialog.open()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        Text {
            text: "基础配置"
            font.pixelSize: 18
            font.bold: true
            color: "#333333"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "电机功率:"
                font.pixelSize: 14
                color: "#333333"
            }

            Slider {
                id: motorSpeedSlider
                Layout.fillWidth: true
                from: 0
                to: 100
                stepSize: 1
                value: userAccount ? userAccount.motorSpeed : 0
            }

            Text {
                text: motorSpeedSlider.value
                font.pixelSize: 14
                font.bold: true
                color: "#1890FF"
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                text: "保存"
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
                    if (userAccount) {
                        userAccount.motorSpeed = motorSpeedSlider.value
                        userAccount.saveConfig()
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "电机旋转时间(ms):"
                font.pixelSize: 14
                color: "#333333"
            }

            TextField {
                id: motorTimeField
                Layout.fillWidth: true
                placeholderText: "请输入旋转时间(ms)"
                font.pixelSize: 14
                text: userAccount ? userAccount.motorTime : ""
                validator: IntValidator { bottom: 0 }
            }

            Button {
                text: "保存"
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
                    if (userAccount) {
                        userAccount.motorTime = parseInt(motorTimeField.text) || 0
                        userAccount.saveConfig()
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "聊天背景透明度:"
                font.pixelSize: 14
                color: "#333333"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Slider {
                    id: chatBgOpacitySlider
                    Layout.fillWidth: true
                    from: 0
                    to: 255
                    stepSize: 1
                    value: userAccount ? userAccount.chatBgOpacity : 255
                }

                Text {
                    text: "0 = 完全透明"
                    font.pixelSize: 11
                    color: "#999999"
                }
            }

            Text {
                text: chatBgOpacitySlider.value
                font.pixelSize: 14
                font.bold: true
                color: "#1890FF"
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                text: "保存"
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
                    if (userAccount) {
                        userAccount.chatBgOpacity = chatBgOpacitySlider.value
                        userAccount.saveConfig()
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: "开机动画:"
                font.pixelSize: 14
                color: "#333333"
                Layout.preferredWidth: 100
            }

            Rectangle {
                Layout.preferredWidth: 160
                Layout.preferredHeight: 120
                color: "#F0F0F0"
                border.width: 1
                border.color: "#D9D9D9"
                radius: 4

                AnimatedImage {
                    id: bootlogoPreview
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 4, sourceSize.width * (parent.height - 4) / sourceSize.height)
                    height: Math.min(parent.height - 4, sourceSize.height * (parent.width - 4) / sourceSize.width)
                    source: root.previewSource
                    fillMode: Image.PreserveAspectFit
                    playing: true
                }
            }

            ColumnLayout {
                spacing: 8

                Button {
                    text: "选择GIF"
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

                    onClicked: fileDialog.open()
                }

                Text {
                    text: "输出320×240，可拖拽缩放"
                    font.pixelSize: 11
                    color: "#999999"
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }
}
