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
    property var lastResult : ""
    property string entityName;
    property string componentName;
    property QtObject entity;
    property bool checked: true;
    property int  col1Width: 0
    property int  col2Width: 0
    property int  col3Width: 0
    property int  col4Width: 0
    property int  col5Width: 0

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
            width: root.col1Width
            Text {
                text: root.entityName + " <font color='blue'>ID: "+ root.entity.entityId() + "</font>";
                anchors.fill: parent;
                anchors.margins: 4
                clip: true
            }
        }
        Item {
            height: parent.height
            width: root.col2Width
            Text {
                text: componentName;
                anchors.fill: parent;
                anchors.margins: 4
                clip: true
            }
        }
        Item {
            height: parent.height
            width: root.col3Width
            Text {
                text: isRPC ? "rpc" : typeof(root.entity[componentName]);
                anchors.fill: parent;
                anchors.margins: 4
                clip: true
            }
        }
        Item {
            height: parent.height
            width: root.col4Width
            Text {
                text: (root.entity[componentName] === undefined || root.entity[componentName].length === undefined || typeof(root.entity[componentName].length) != "number") ? "" : root.entity[componentName].length.toString();
                anchors.fill: parent;
                anchors.margins: 4
                clip: true
            }
        }



        Item {
            height: parent.height
            width: root.col5Width - 110
            TextEdit {
                id: valueField
                readOnly: true
                text: {
                    if(isRPC){
                        return "Last RPC Result: "+root.lastResult
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
                onVisibleChanged: {
                    forceActiveFocus();
                }

                onEditingFinished: {
                    visible=false;
                    var type = typeof(root.entity[componentName]);
                    if(type === "string"){
                        root.entity[componentName]=text;
                    }else if(type === "boolean"){
                        if(text === "true"){
                            root.entity[componentName]=true;
                        }else if(text === "false"){
                            root.entity[componentName]=false;
                        }
                    }else if(type === "number"){
                        var number = parseFloat(text);
                        root.entity[componentName]= number;
                    }else if(isRPC && root.rpcTrace === undefined){
                        root.rpcTrace=entity.invokeRPC(componentName, stringToQVariantMap(text))
                    }
                }
                Keys.onEscapePressed: {
                    visible=false;
                }
            }
        }


        Connections {
            target: root.entity
            onSigRPCFinished: {
                if(t_resultData["RemoteProcedureData::errorMessage"]) {
                    console.warn("RPC error:" << t_resultData["RemoteProcedureData::errorMessage"]);
                }else if(t_identifier === root.rpcTrace){
                    root.rpcTrace = undefined;
                    if(t_resultData["RemoteProcedureData::resultCode"] === 4) { //EINTR, the search was canceled
                        root.lastResult = "EINTR";
                    }else{
                        root.rpcTrace = undefined;
                        root.lastResult=t_resultData["RemoteProcedureData::Return"];
                        if(root.lastResult === "" || root.lastResult === undefined){
                            root.lastResult="NoData";
                        }

                    }
                }
            }
            onSigRPCProgress: {
                if(t_identifier === searchProgressId) {
                    ({"modelData":t_progressData["ZeraDBLogger::searchResultEntry"]});
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
                        if(isRPC === true)
                        {
                            console.info('var tracerUID = VeinEntity.getEntity("'+root.entityName+'").invokeRPC("'+componentName+'", <parameterObject>)');
                        }
                        else
                        {
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
                        if(isRPC === true)
                        {
                            console.info('var tracerUID = VeinEntity.getEntity("'+root.entityName+'").invokeRPC("'+componentName+'", <parameterObject>)');
                        }
                        else
                        {
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
                    if(!valueInput.visible){
                        if( type !== "string" && type !== "boolean" && type !== "number" && isRPC === false){
                            return "Copy";
                        }else if(isRPC){
                            return "Call";
                        }else{
                            return "Edit"
                        }
                    }else{
                        return "Close"
                    }
                }
                background: Rectangle{
                    id: backColor
                    color: {
                        if(buttonArea.pressed){
                            return "blue";
                        }else{
                            return buttonArea.containsMouse ? "grey"  : "white";
                        }
                    }
                }

                MouseArea {
                    id: buttonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressedChanged: {
                        if(pressed && !valueInput.visible){
                            valueInput.visible=true;
                            valueInput.text=valueToString(root.entity[componentName]);
                            valueInput.selectAll();
                        }else if(pressed && valueInput.visible){
                            valueInput.visible=false;
                        }



                    }

                }
            }
        }
    }
}

