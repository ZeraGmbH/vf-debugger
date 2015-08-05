import QtQuick 2.0
import VeinEntity 1.0

Rectangle {
  id: root
  property string entityName;
  property var entity;

  height: componentModel.count*30

  onEntityNameChanged: {
    entity = VeinEntity.getEntity(entityName);

    var keyList = entity.keys();
    for(var i=0; i<keyList.length; ++i)
    {
      var componentName = keyList[i];
      if(componentName !== "EntityName")
      {
        componentModel.append({"componentName":componentName})
      }
    }
  }

  ListModel {
    id: componentModel
  }

  ListView {
    id: entView
    clip: true
    anchors.fill: parent
    model: componentModel

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

    delegate: Row {
      height: 30
      width: root.width
      spacing: 0

      Rectangle {
        height: parent.height
        width: parent.width/100*12
        Text { text: root.entityName; anchors.fill: parent; anchors.margins: 4 }
      }
      Rectangle {
        height: parent.height
        width: parent.width/100*20
        Text { text: componentName; anchors.fill: parent; anchors.margins: 4 }
      }
      Rectangle {
        height: parent.height
        width: parent.width/100*8
        Text { text: typeof(root.entity[componentName]); anchors.fill: parent; anchors.margins: 4 }
      }
      Rectangle {
        height: parent.height
        width: parent.width/100*10
        Text { text: root.entity[componentName].length === undefined ? "" : root.entity[componentName].length.toString(); anchors.fill: parent; anchors.margins: 4 }
      }
      Rectangle {
        height: parent.height
        width: root.width/100*46
        Text { text: root.entity[componentName].toString(); anchors.fill: parent; anchors.margins: 4 }
      }
      Item {
        height: parent.height-4
        width: root.width/100*5
        Rectangle {
          height:parent.height - anchors.margins
          width: parent.height - anchors.margins
          anchors.centerIn: parent
          anchors.margins: 8
          color: "steelblue"
          border.width: 1
          border.color: "black"
          radius: Math.round(height+width/2)
          smooth: true
          antialiasing: true
          MouseArea {
            anchors.fill: parent
            onPressedChanged: {
              parent.color = pressed ? "lightsteelblue" : "steelblue"
            }
            onReleased: {
              console.log('VeinEntity.getEntity("'+root.entityName+'")["'+componentName+'"]')
            }
          }
        }
      }
    }
  }
}

