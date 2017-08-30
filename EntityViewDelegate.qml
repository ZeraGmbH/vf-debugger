import QtQuick 2.0
import VeinEntity 1.0
import QtQuick.Controls 2.0
import SortFilterProxyModel 0.2

Rectangle {
  id: root
  height: 30
  border.color: "#44000000"
  width: root.width
  property string entityName;
  property string componentName;
  property QtObject entity;
  property bool checked: true;

  property string filterPattern;

  function valueToString(t_value) {
    var retVal = "";
    if(t_value !== undefined)
    {
      retVal = t_value.toString();
      if (retVal === "[object Object]")
      {
        retVal = JSON.stringify(t_value);
      }
    }

    return retVal;
  }

  Row {
    anchors.fill: parent
    spacing: 0
    clip: true

    Item {
      height: parent.height
      width: parent.width*0.16
      Text {
        text: root.entityName + " <font color='blue'>ID: "+ root.entity.entityId() + "</font>";
        anchors.fill: parent;
        anchors.margins: 4
      }
    }
    Item {
      height: parent.height
      width: parent.width*0.16
      Text {
        text: componentName;
        anchors.fill: parent;
        anchors.margins: 4
      }
    }
    Item {
      height: parent.height
      width: parent.width*0.08
      Text {
        text: typeof(root.entity[componentName]);
        anchors.fill: parent;
        anchors.margins: 4
      }
    }
    Item {
      height: parent.height
      width: parent.width*0.10
      Text {
        text: (root.entity[componentName] === undefined || root.entity[componentName].length === undefined || typeof(root.entity[componentName].length) != "number") ? "" : root.entity[componentName].length.toString();
        anchors.fill: parent;
        anchors.margins: 4
      }
    }
    Item {
      height: parent.height
      width: root.width*0.41
      Text {
        text: valueToString(root.entity[componentName]);
        anchors.fill: parent;
        anchors.margins: 4
      }
    }
    Item {
      height: parent.height-4
      width: root.width*0.05
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
    Item {
      height: parent.height-4
      width: root.width*0.05
      Rectangle {
        height:parent.height - anchors.margins
        width: parent.height - anchors.margins
        anchors.centerIn: parent
        anchors.margins: 8
        color: "green"
        border.width: 1
        border.color: "black"
        radius: Math.round(height+width/2)
        smooth: true
        antialiasing: true
        MouseArea {
          anchors.fill: parent
          onPressedChanged: {
            parent.color = pressed ? "purple" : "green"
          }
          onReleased: {
            console.log('VeinEntity.getEntity("'+root.entityName+'")["'+componentName+'"]:', valueToString(VeinEntity.getEntity(root.entityName)[componentName]));
          }
        }
      }
    }
  }
}

