import QtQuick 2.0

Rectangle {
    id: root


    MouseArea{
        id: dragAreaR
        property int oldMouseX
        anchors.right:  parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 5
        hoverEnabled: true
        cursorShape: containsMouse ? Qt.SizeHorCursor : Qt.ArrowCursor
        onPressed: {
            oldMouseX=mouseX
        }

        onPositionChanged: {
            if (pressed) {
                parent.width = parent.width + (mouseX - oldMouseX)
            }
        }
    }

//    MouseArea{
//        id: dragAreaL
//        property int oldMouseX
//        anchors.left:  parent.left
//        anchors.top: parent.top
//        anchors.bottom: parent.bottom
//        width: 5
//        hoverEnabled: true
//        cursorShape: containsMouse ? Qt.SizeHorCursor : Qt.ArrowCursor
//        onPressed: {
//            oldMouseX=mouseX
//        }

//        onPositionChanged: {
//            if (pressed) {
//                parent.width = parent.width - (mouseX - oldMouseX)
//            }
//        }
//    }



}
