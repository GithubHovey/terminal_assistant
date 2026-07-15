import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#FFFFFF"

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
    }
}
