import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "agent"

Rectangle {
    id: root
    color: "#F5F5F5"
    
    property int currentIndex: 0
    
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
                        { name: "其他", icon: "⚙️" }
                    ]
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: root.currentIndex === index ? "#1890FF" : (mouseArea.containsMouse ? "#E6F7FF" : "transparent")
                        radius: 4
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            
                            Text {
                                text: modelData.icon
                                font.pixelSize: 16
                                color: root.currentIndex === index ? "#FFFFFF" : "#333333"
                            }
                            
                            Text {
                                text: modelData.name
                                font.pixelSize: 14
                                color: root.currentIndex === index ? "#FFFFFF" : "#333333"
                                Layout.fillWidth: true
                            }
                        }
                        
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
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
                OtherPage {}
            }
        }
    }
}