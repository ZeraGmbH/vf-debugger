import QtQuick 2.0
import VeinEntity 1.0
import QtQuick.Controls 2.0
import SortFilterProxyModel 0.2

Rectangle {
    id: root
    height: 30
    border.color: "#44000000"
    width: root.width
    property var rpcTrace : undefined;
    property var lastResult: "{}"
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
            if (retVal === "[object Object]") {
                retVal = JSON.stringify(t_value);
            }
        }
        return retVal;
    }

    function stringToQVariantMap(parameters){
        if(parameters === ""){
            parameters="{}"
        }
        var JsonObj= JSON.parse(parameters);
        var ret=JsonObj;
        return ret;
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
            width: parent.width*0.2
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
                text: isRPC ? "rpc" : typeof(root.entity[componentName]);
                anchors.fill: parent;
                anchors.margins: 4
            }
        }
        Item {
            height: parent.height
            width: parent.width*0.06
            Text {
                text: (root.entity[componentName] === undefined || root.entity[componentName].length === undefined || typeof(root.entity[componentName].length) != "number") ? "" : root.entity[componentName].length.toString();
                anchors.fill: parent;
                anchors.margins: 4
            }
        }
        Item {
            height: parent.height
            width: root.width*0.43
            TextEdit {
                id: valueField
                readOnly: true
                text: {
                    if(isRPC) {
                        return root.rpcTrace === undefined ? "Result: " + root.lastResult : "Running..."
                    }
                    return valueToString(root.entity[componentName]);
                }
                anchors.fill: parent;
                anchors.margins: 4
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.MidButton || Qt.LeftButton
                    onPressed: {
                        valueField.selectAll();
                        valueField.copy();
                        valueField.deselect();
                    }
                }
            }
            TextField {
                id: valueInput
                anchors.fill: parent;
                anchors.margins: 0
                visible: false
                selectByMouse: true
                maximumLength: 1000000
                onVisibleChanged: {
                    forceActiveFocus();
                }
                onAccepted: {
                    visible=false;
                    var type = typeof(root.entity[componentName]);
                    if(type === "string") {
                        root.entity[componentName]=text;
                    } else if(type === "boolean") {
                        if(text === "true"){
                            root.entity[componentName]=true;
                        } else if(text === "false") {
                            root.entity[componentName]=false;
                        }
                    } else if(type === "number") {
                        var number = parseFloat(text);
                        root.entity[componentName]= number;
                    } else if(isRPC && root.rpcTrace === undefined) {
                        root.rpcTrace = entity.invokeRPC(componentName, stringToQVariantMap(text))
                    }
                }
                Keys.onEscapePressed: {
                    visible=false;
                }
            }
        }
        Connections {
            target: root.entity
            function onSigRPCFinished(t_identifier, t_resultData) {
                if(t_identifier === root.rpcTrace) {
                    root.rpcTrace = undefined;
                    if(t_resultData["RemoteProcedureData::errorMessage"]) {
                        console.error("RPC error:", t_resultData["RemoteProcedureData::errorMessage"]);
                    }
                    // deep copy
                    let strResult = JSON.stringify(t_resultData)
                    let lastResult = JSON.parse(strResult)
                    // shorten
                    delete lastResult["RemoteProcedureData::callID"]
                    strResult = JSON.stringify(lastResult)
                    strResult = strResult.replace(new RegExp("RemoteProcedureData::", "g"), "<RPD>::")
                    root.lastResult = strResult
                }
            }
            function onSigRPCProgress(t_identifier, t_progressData) {
                if(t_identifier === searchProgressId) {
                    // No more supported currently - but will be revived
                }
            }
        }

        Item {
            height: parent.height-4
            width: root.width*0.02
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
                        if(isRPC === true) {
                            console.info('var tracerUID = VeinEntity.getEntity("'+root.entityName+'").invokeRPC("'+componentName+'", <parameterObject>)');
                        }
                        else {
                            console.info('VeinEntity.getEntity("'+root.entityName+'")["'+componentName+'"]')
                        }
                    }
                }
            }
        }
        Item {
            height: parent.height-4
            width: root.width*0.02
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
                        if(isRPC === true) {
                            console.info('var tracerUID = VeinEntity.getEntity("'+root.entityName+'").invokeRPC("'+componentName+'", <parameterObject>)');
                        }
                        else {
                            console.info('VeinEntity.getEntity("'+root.entityName+'")["'+componentName+'"]:', valueToString(VeinEntity.getEntity(root.entityName)[componentName]));
                        }
                    }
                }
            }
        }
        Item{
            height: parent.height-4
            width: root.width*0.02
            Label{
                height:parent.height - anchors.margins
                width: parent.width - anchors.margins
                anchors.centerIn: parent
                anchors.margins: 0
                color: valueInput.visible ?  "red" : "black"
                text: {
                    var type = typeof(root.entity[componentName]);
                    if(!valueInput.visible) {
                        if( type !== "string" && type !== "boolean" && type !== "number" && isRPC === false) {
                            return "Copy";
                        } else if(isRPC) {
                            return "Call";
                        } else {
                            return "Edit"
                        }
                    } else {
                        return "Close"
                    }
                }
                background: Rectangle{
                    id: backColor
                    color: {
                        if(buttonArea.pressed) {
                            return "blue";
                        } else {
                            return buttonArea.containsMouse ? "grey"  : "white";
                        }
                    }
                }
                MouseArea {
                    id: buttonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressedChanged: {
                        if(pressed && !valueInput.visible) {
                            valueInput.visible=true;
                            valueInput.text=valueToString(root.entity[componentName]);
                            valueInput.selectAll();
                        } else if(pressed && valueInput.visible) {
                            valueInput.visible=false;
                        }
                    }
                }
            }
        }
    }
}

