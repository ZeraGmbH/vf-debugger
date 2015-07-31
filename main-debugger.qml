import QtQuick 2.2
import QtQuick.Window 2.2
import VeinEntity 1.0

Window {
  id: root
  visible: true

  width: 800
  height: 600

  Component.onCompleted: {
    VeinEntity.setRequiredIds(VeinEntity.getEntity("_System")["Entities"])
    console.log(VeinEntity.getEntity("_System")["Entities"])
  }

  Connections {
    target: VeinEntity
    onSigEntityAvailable: {
      console.log("AVAILABLE", t_entityName)
      fakeModel.append({"name":t_entityName});
    }
  }

  ListModel {
    id: fakeModel
  }


  Row {
    id: headLine
    anchors.top: parent.top
    height:  30
    width: root.width
    spacing: 0
    Rectangle {
      color: "lightblue"
      height: parent.height
      width: parent.width/100*12
      border.width: 1
      border.color: "black"
      Text { text: "Entity name"; font.bold: true; anchors.fill: parent; anchors.margins: 4 }
    }
    Rectangle {
      color: "lightblue"
      height: parent.height
      width: parent.width/100*20
      border.width: 1
      border.color: "black"
      Text { text: "Component name"; font.bold: true; anchors.fill: parent; anchors.margins: 4 }
    }
    Rectangle {
      color: "lightblue"
      height: parent.height
      width: parent.width/100*8
      border.width: 1
      border.color: "black"
      Text { text: "Type"; font.bold: true; anchors.fill: parent; anchors.margins: 4 }
    }
    Rectangle {
      color: "lightblue"
      height: parent.height
      width: parent.width/100*10
      border.width: 1
      border.color: "black"
      Text { text: "Size"; font.bold: true; anchors.fill: parent; anchors.margins: 4 }
    }
    Rectangle {
      color: "lightblue"
      height: parent.height
      width: root.width/100*50
      border.width: 1
      border.color: "black"
      Text { text: "Value"; font.bold: true; anchors.fill: parent; anchors.margins: 4 }
    }
  }

  ListView {
    id: entView
    clip: true
    anchors.fill: parent
    anchors.topMargin: headLine.height
    model: fakeModel

    remove: Transition {
      ParallelAnimation {
        NumberAnimation { property: "opacity"; to: 0; duration: 300 }
        NumberAnimation { properties: "x"; to: 1000; duration: 300 }
      }
    }

    add: Transition {
      ParallelAnimation {
        NumberAnimation { property: "opacity"; to: 1; duration: 300 }
        NumberAnimation { properties: "x"; from: 1000; duration: 300 }
      }
    }
    delegate: EntityViewDelegate {width: root.width; entityName: name}
  }
}
