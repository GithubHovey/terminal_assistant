import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "agent"

Rectangle {
    id: root
    color: "#F5F5F5"
    
    property int currentIndex: 0
    property bool hasApiKey: userAccount && userAccount.apiKey.length > 0
    
    readonly property var lockedIndices: [1, 2, 3, 4]
    
    function isLocked(idx) {
        return lockedIndices.indexOf(idx) !== -1 && !hasApiKey
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        Rectangle {
            Layout.preferredWidth: 180
            Layout.fillHeight: true
            color: "#FFFFFF"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5
                
                Repeater {
                    model: [
                        { name: "账号", icon: "👤" },
                        { name: "热词库", icon: "📝" },
                        { name: "知识库", icon: "📚" },
                        { name: "角色", icon: "🎭" },
                        { name: "声音库", icon: "🎤" },
                        { name: "其他", icon: "⚙️" }
                    ]
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: {
                            if (root.isLocked(index)) return "#F0F0F0"
                            return root.currentIndex === index ? "#1890FF" : (mouseArea.containsMouse ? "#E6F7FF" : "transparent")
                        }
                        radius: 4
                        opacity: root.isLocked(index) ? 0.5 : 1.0
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            
                            Text {
                                text: modelData.icon
                                font.pixelSize: 16
                                color: root.currentIndex === index && !root.isLocked(index) ? "#FFFFFF" : "#333333"
                            }
                            
                            Text {
                                text: modelData.name
                                font.pixelSize: 14
                                color: root.currentIndex === index && !root.isLocked(index) ? "#FFFFFF" : "#333333"
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                visible: root.isLocked(index)
                                text: "🔒"
                                font.pixelSize: 12
                            }
                        }
                        
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: root.isLocked(index) ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                            onClicked: {
                                if (root.isLocked(index)) return
                                root.currentIndex = index
                            }
                        }
                    }
                }
                
                Item {
                    Layout.fillHeight: true
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#F5F5F5"
            
            StackLayout {
                anchors.fill: parent
                currentIndex: root.currentIndex
                
                AccountPage {}
                HotWordsPage {}
                KnowledgeBasePage {}
                RolePage {}
                VoiceLibraryPage {}
                OtherPage {}
            }
            
            Rectangle {
                visible: root.isLocked(root.currentIndex)
                anchors.fill: parent
                color: "#F5F5F5"
                z: 10
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "🔒"
                        font.pixelSize: 48
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "请先在「账号」页面配置 API Key"
                        font.pixelSize: 16
                        color: "#999999"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}