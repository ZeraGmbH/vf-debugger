import QtQuick 2.2
import QtQuick.Window 2.2
import VeinEntity 1.0
import QtQuick.Controls 2.0
import SortFilterProxyModel 0.2
import QtQuick.Layouts 1.3

Window {
  id: root
  visible: true

  width: 1024
  height: 768

  property int totalProperties: 0
  property int totalEntities: 0
  property bool entitiesLoaded: false
  property string filterPattern: searchField.text

  Component.onCompleted: {
    console.log(VeinEntity.getEntity("_System")["Entities"])
    delayedLoader.start()
  }

  Timer {
    id: delayedLoader
    interval: 50
    repeat: false
    onTriggered: {
      var entIds = VeinEntity.getEntity("_System")["Entities"];
      if(entIds !== undefined)
      {
        entIds.push(0);
      }
      else
      {
        entIds = [0];
      }

      VeinEntity.setRequiredIds(entIds)
      entitiesLoaded = true
    }
  }

  Connections {
    target: VeinEntity
    onSigEntityAvailable: {
      if(entitiesLoaded === true)
      {
        var tmpEntity = VeinEntity.getEntity(t_entityName);
        var tmpEntityId = tmpEntity.entityId()
        console.log(qsTr("AVAILABLE '%1'").arg(t_entityName));
        totalProperties += tmpEntity.propertyCount();
        for(var i = 0; i< tmpEntity.keys().length; ++i)
        {
          fakeModel.append({"entId": tmpEntityId, "entName":t_entityName, "compName": tmpEntity.keys()[i]});
        }
        ++totalEntities;
      }
    }
  }

  ListModel {
    id: fakeModel
  }

  GridLayout {
    id: headerBar
    height: 48
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    rowSpacing: 8
    rows: 1
    Text {
      text: qsTr("Total entities: %1\t Total properties: %2\t Search results: %3").arg(root.totalEntities).arg(root.totalProperties).arg(entityProxyModel.count)
      anchors.verticalCenter: parent.verticalCenter
    }
    Item {
      Layout.fillWidth: true
    }

    TextField {
      id: searchField

      placeholderText: "Regex search"
      height: parent.height
      selectByMouse: true
    }
    Button {
      text: "Clear"
      onPressed: searchField.clear()
      enabled: searchField.text.length > 0
    }
  }


  Row {
    id: headLine
    anchors.top: headerBar.bottom
    height:  30
    width: root.width
    spacing: 0
    Rectangle {
      color: "lightblue"
      height: parent.height
      width: parent.width*0.16
      border.width: 1
      border.color: "black"
      Text { text: "Entity name"; font.bold: true; anchors.fill: parent; anchors.margins: 4 }
    }
    Rectangle {
      color: "lightblue"
      height: parent.height
      width: parent.width*0.16
      border.width: 1
      border.color: "black"
      Text { text: "Component name"; font.bold: true; anchors.fill: parent; anchors.margins: 4 }
    }
    Rectangle {
      color: "lightblue"
      height: parent.height
      width: parent.width*0.08
      border.width: 1
      border.color: "black"
      Text { text: "Type"; font.bold: true; anchors.fill: parent; anchors.margins: 4 }
    }
    Rectangle {
      color: "lightblue"
      height: parent.height
      width: parent.width*0.10
      border.width: 1
      border.color: "black"
      Text { text: "Size"; font.bold: true; anchors.fill: parent; anchors.margins: 4 }
    }
    Rectangle {
      color: "lightblue"
      height: parent.height
      width: root.width*0.50
      border.width: 1
      border.color: "black"
      Text { text: "Value"; font.bold: true; anchors.fill: parent; anchors.margins: 4 }
    }
  }

  SortFilterProxyModel {
    id: entityProxyModel
    sourceModel: fakeModel
    sorters: [
      RoleSorter { roleName: "entName"; },
      RoleSorter { roleName: "compName" }
    ]

    filters: [
      AnyOf {
        RegExpFilter {
          roleName: "entId"
          pattern: searchField.text
          caseSensitivity: Qt.CaseInsensitive
        }
        RegExpFilter {
          roleName: "entName"
          pattern: searchField.text
          caseSensitivity: Qt.CaseInsensitive
        }
        RegExpFilter {
          roleName: "compName"
          pattern: searchField.text
          caseSensitivity: Qt.CaseInsensitive
        }
      }
    ]
  }

  ListView {
    id: entView
    clip: true
    anchors.fill: parent
    anchors.topMargin: headLine.height + headerBar.height
    model: entityProxyModel

    delegate: EntityViewDelegate {
      width: root.width;
      entityName: entName;
      componentName: compName;
      entity: VeinEntity.getEntity(entName)
      color: index%2>0 ? "white" : "ghostwhite"
    }
  }
}
