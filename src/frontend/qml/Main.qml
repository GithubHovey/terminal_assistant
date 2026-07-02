import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1080
    height: 720
    title: qsTr("深空联合助手")
    color: "#FFFFFF"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#FFFFFF"

            CustomTabBar {
                id: tabBar
                anchors.fill: parent

                TabButton {
                    text: qsTr("基础配置")
                    font.pixelSize: 14
                }
                TabButton {
                    text: qsTr("智能体配置")
                    font.pixelSize: 14
                }
                TabButton {
                    text: qsTr("电台配置")
                    font.pixelSize: 14
                }
                TabButton {
                    text: qsTr("维护")
                    font.pixelSize: 14
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
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#FFFFFF"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                LogPanel {
                    id: logPanel
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                ApplyButton {
                    id: applyButton
                    Layout.preferredWidth: 120
                    Layout.fillHeight: true
                    text: qsTr("应用")
                    onClicked: {
                        console.log("应用按钮被点击")
                    }
                }
            }
        }
    }
}