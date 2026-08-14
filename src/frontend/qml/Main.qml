import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "components"
import "pages"

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1080
    height: 720
    title: qsTr("深空联合助手") + " v" + appVersion
    color: "#FFFFFF"

    Connections {
        target: logger
        function onNewLogEntry(entry) {
            logPanel.appendLog(entry)
        }
    }

    Connections {
        target: sdCardManager
        function onApplyFinished(success, message) {
            dialogMsg.text = message
            dialogOverlay.visible = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: "#FFFFFF"

            CustomTabBar {
                id: tabBar
                anchors.fill: parent

                TabButton {
                    text: qsTr("基础配置")
                    font.pixelSize: 20
                    font.bold: true
                    width: implicitWidth + 40
                    
                    background: Rectangle {
                        color: tabBar.currentIndex === 0 ? "#1890FF" : (parent.hovered ? "#E6F7FF" : "#FFFFFF")
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: tabBar.currentIndex === 0 ? "#FFFFFF" : "#333333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                TabButton {
                    text: qsTr("智能体配置")
                    font.pixelSize: 20
                    font.bold: true
                    width: implicitWidth + 40
                    
                    background: Rectangle {
                        color: tabBar.currentIndex === 1 ? "#1890FF" : (parent.hovered ? "#E6F7FF" : "#FFFFFF")
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: tabBar.currentIndex === 1 ? "#FFFFFF" : "#333333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                TabButton {
                    text: qsTr("电台配置")
                    font.pixelSize: 20
                    font.bold: true
                    width: implicitWidth + 40
                    
                    background: Rectangle {
                        color: tabBar.currentIndex === 2 ? "#1890FF" : (parent.hovered ? "#E6F7FF" : "#FFFFFF")
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: tabBar.currentIndex === 2 ? "#FFFFFF" : "#333333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                TabButton {
                    text: qsTr("维护")
                    font.pixelSize: 20
                    font.bold: true
                    width: implicitWidth + 40
                    
                    background: Rectangle {
                        color: tabBar.currentIndex === 3 ? "#1890FF" : (parent.hovered ? "#E6F7FF" : "#FFFFFF")
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: tabBar.currentIndex === 3 ? "#FFFFFF" : "#333333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#F5F5F5"

            StackLayout {
                anchors.fill: parent
                currentIndex: tabBar.currentIndex

                BasicConfigPage {
                    id: basicConfigPage
                }

                AgentConfigPage {
                    id: agentConfigPage
                }

                RadioConfigPage {
                    id: radioConfigPage
                }

                MaintenancePage {
                    id: maintenancePage
                }
            }

            Rectangle {
                visible: !sdCardManager.connected && tabBar.currentIndex !== 3
                anchors.fill: parent
                color: "#E6FFFFFF"
                z: 10

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "请先连接SD卡"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#999999"
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "连接SD卡后即可编辑配置内容"
                        font.pixelSize: 14
                        color: "#BBBBBB"
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: "#FFFFFF"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.preferredWidth: 400
                    Layout.fillHeight: true
                    spacing: 6

                    Button {
                        id: scanBtn
                        Layout.preferredWidth: 56
                        Layout.fillHeight: true
                        text: "刷新"
                        enabled: sdCardManager && !sdCardManager.connected

                        background: Rectangle {
                            color: parent.pressed ? "#D9D9D9" : (parent.hovered ? "#E6F7FF" : "#F0F0F0")
                            border.width: 1
                            border.color: "#D9D9D9"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: "#333333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            if (sdCardManager) {
                                sdCardManager.refreshDrives()
                            }
                        }
                    }

                    ComboBox {
                        id: sdCardCombo
                        Layout.preferredWidth: 140
                        Layout.fillHeight: true
                        enabled: sdCardManager && !sdCardManager.connected
                        model: sdCardManager ? sdCardManager.availableDrives : []
                        textRole: "display"

                        delegate: ItemDelegate {
                            width: sdCardCombo.width
                            contentItem: Text {
                                text: modelData
                                font.pixelSize: 13
                                color: "#333333"
                                verticalAlignment: Text.AlignVCenter
                            }
                            highlighted: sdCardCombo.highlightedIndex === index
                        }
                    }

                    RowLayout {
                        spacing: 4
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: sdCardManager && sdCardManager.connected ? "#52C41A" : "#D9D9D9"
                        }
                        Text {
                            text: sdCardManager && sdCardManager.connected
                                  ? sdCardManager.formatSize(sdCardManager.freeSpace) + "/" + sdCardManager.formatSize(sdCardManager.cardSize)
                                  : "未连接"
                            font.pixelSize: 12
                            color: "#666666"
                        }
                    }

                    Button {
                        Layout.preferredWidth: 56
                        Layout.fillHeight: true
                        text: sdCardManager && sdCardManager.connected ? "断开" : "连接"
                        enabled: (sdCardManager && sdCardManager.connected) || sdCardCombo.currentIndex >= 0

                        background: Rectangle {
                            color: sdCardManager && sdCardManager.connected
                                   ? (parent.pressed ? "#FF4D4F" : (parent.hovered ? "#FF7875" : "#FF4D4F"))
                                   : (parent.pressed ? "#096DD9" : (parent.hovered ? "#40A9FF" : "#1890FF"))
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            font.bold: true
                            color: "#FFFFFF"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            if (!sdCardManager) return
                            if (sdCardManager.connected) {
                                sdCardManager.disconnectCard()
                            } else {
                                var drive = sdCardManager.availableDrives[sdCardCombo.currentIndex]
                                var letter = drive.letter
                                sdCardManager.connectCard(letter)
                            }
                        }
                    }
                }

                LogPanel {
                    id: logPanel
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                ApplyButton {
                    id: applyButton
                    Layout.preferredWidth: 120
                    Layout.fillHeight: true
                    text: qsTr("应用到终端SD卡")
                    onClicked: {
                        if (!sdCardManager.connected) {
                            logger.logWarning("请先连接SD卡")
                            dialogMsg.text = "请先连接SD卡"
                            dialogOverlay.visible = true
                            return
                        }
                        logger.logInfo("开始应用资源到SD卡...")
                        sdCardManager.applyResources()
                    }
                }
            }
        }
    }

    Rectangle {
        id: dialogOverlay
        visible: false
        anchors.fill: parent
        color: "#80000000"
        z: 999

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Rectangle {
            anchors.centerIn: parent
            width: 300
            height: 120
            radius: 8
            color: "#FFFFFF"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    id: dialogMsg
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: 14
                    color: "#333333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    text: "确定"

                    background: Rectangle {
                        color: parent.pressed ? "#096DD9" : (parent.hovered ? "#40A9FF" : "#1890FF")
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 13
                        font.bold: true
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: dialogOverlay.visible = false
                }
            }
        }
    }
}