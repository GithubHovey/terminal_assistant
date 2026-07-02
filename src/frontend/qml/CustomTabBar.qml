import QtQuick
import QtQuick.Controls

TabBar {
    id: control
    background: Rectangle {
        color: "#FFFFFF"
    }
    
    contentItem: ListView {
        model: control.contentModel
        currentIndex: control.currentIndex
        
        spacing: 2
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickDirection
        snapMode: ListView.SnapToItem
        
        highlightMoveDuration: 0
        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: 40
        preferredHighlightEnd: width - 40
    }
    
    property color accentColor: "#1890FF"
    property color textColor: "#333333"
    property color selectedTextColor: "#1890FF"
}