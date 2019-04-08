import QtQuick 2.2
import QtQuick.Window 2.2
import VeinEntity 1.0
import EvStats 1.0
import QtQuick.Controls 2.0
import SortFilterProxyModel 0.2
import QtQuick.Layouts 1.3

Window {
  id: root
  visible: true

  width: 1280
  height: 768

  property int totalProperties: 0
  property int totalEntities: 0
  property int totalRPC: 0
  property bool entitiesLoaded: false
  property string filterPattern: searchField.text

  Component.onCompleted: {
    showMaximized();
    var systemEntity = VeinEntity.getEntity("_System");
    console.log("onCompleted", systemEntity["Entities"])
    delayedLoader.start()

    totalProperties += systemEntity.propertyCount();
    for(var i = 0; i< systemEntity.keys().length; ++i)
    {
      fakeModel.append({"entId": 0, "entName":systemEntity.EntityName, "compName": systemEntity.keys()[i], "isRPC": false});
    }
    var rpcList = systemEntity.remoteProcedures;
    totalRPC += rpcList.length;
    for(var j = 0; j<rpcList.length; ++j)
    {
      fakeModel.append({"entId": 0, "entName":systemEntity.EntityName, "compName": rpcList[j], "isRPC": true});
    }

    ++totalEntities;
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

      for(var tmpId in entIds)
      {
        VeinEntity.entitySubscribeById(entIds[tmpId]);
      }

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
          fakeModel.append({"entId": tmpEntityId, "entName":t_entityName, "compName": tmpEntity.keys()[i], "isRPC": false});
        }
        var rpcList = tmpEntity.remoteProcedures;
        totalRPC += rpcList.length;
        for(var j = 0; j<rpcList.length; ++j)
        {
          fakeModel.append({"entId": tmpEntityId, "entName":t_entityName, "compName": rpcList[j], "isRPC": true});
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
      text: qsTr("Total entities: %1\t Total properties: %2\t Total remote procedures: %3\t Search results: %4").arg(root.totalEntities).arg(root.totalProperties).arg(root.totalRPC).arg(entityProxyModel.count)
      anchors.verticalCenter: parent.verticalCenter
    }
    Text {
      text: "Events per second: " + EvStats.eventsPerSecond;
    }
    Text {
      text: "Events per minute: " + EvStats.eventsPerMinute;
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
      width: parent.width*0.2
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
      width: parent.width*0.06
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

  Component {
    id: sectionHeading
    Rectangle {
      width: root.width
      height: childrenRect.height
      color: "lightblue"

      Text {
        text: section
        font.bold: true
        font.pixelSize: 20
        x: 4
      }
    }
  }

  ListView {
    id: entView
    clip: true
    anchors.fill: parent
    anchors.topMargin: headLine.height + headerBar.height
    model: entityProxyModel
    section.property: "entName"
    section.criteria: ViewSection.FullString
    section.delegate: sectionHeading
    section.labelPositioning: ViewSection.InlineLabels | ViewSection.CurrentLabelAtStart // | ViewSection.NextLabelAtEnd

    delegate: EntityViewDelegate {
      width: root.width;
      entityName: entName;
      componentName: compName;
      entity: VeinEntity.getEntity(entName)
      color: index%2>0 ? "white" : "ghostwhite"
    }
  }
}
