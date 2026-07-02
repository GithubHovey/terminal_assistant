import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "#FFFFFF"
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        Rectangle {
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            color: "#FAFAFA"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "#FFFFFF"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "角色列表"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }
                }
                
                ListView {
                    id: roleListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    model: ListModel {
                        ListElement { roleName: "user"; canDelete: false }
                    }
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 90
                        color: roleListView.currentIndex === index ? "#E6F7FF" : (itemMouseArea.containsMouse ? "#F0F0F0" : "transparent")
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Rectangle {
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 60
                                radius: 30
                                color: "#CCCCCC"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: roleName.charAt(0).toUpperCase()
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#FFFFFF"
                                }
                            }
                            
                            Text {
                                text: roleName
                                font.pixelSize: 14
                                color: roleListView.currentIndex === index ? "#1890FF" : "#333333"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        
                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                roleListView.currentIndex = index
                            }
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#FFFFFF"
                    
                    Button {
                        anchors.centerIn: parent
                        text: "+ 添加角色"
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
                            roleListView.model.append({ roleName: "新角色", canDelete: true })
                        }
                    }
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFFFFF"
            
            Text {
                anchors.centerIn: parent
                text: "角色详情编辑区"
                font.pixelSize: 16
                color: "#999999"
            }
        }
    }
}