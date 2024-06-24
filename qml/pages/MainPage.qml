import QtQuick 2.0
import Sailfish.Silica 1.0

import StringObject 1.0 //----second way CPPtoQML

Page {
    objectName: "mainPage"
    allowedOrientations: Orientation.All

    StringObject {
        id: stringObject //----second way CPPtoQML
    }

    property string colorRectStr: "red"

    Column {
        width: parent.width
        spacing: Theme.paddingMedium

        PageHeader {
            objectName: "pageHeader"
            title: qsTr("MobAdaptUi")
            extraContent.children: [
                IconButton {
                    objectName: "aboutButton"
                    icon.source: "image://theme/icon-m-about"
                    anchors.verticalCenter: parent.verticalCenter

                    onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            ]
        }

        Rectangle {
            id: colorRect
            width: 200
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter
            color: colorRectStr
        }
        Button {
            text: "Change"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                colorRectStr = colorRectStr === "red" ? "green" : "red"
            }
        }
        TextArea {
            id: textArea
            horizontalAlignment: Text.AlignHCenter
            readOnly: true
            text: stringObject.value
        }
        TextField {
            id: textField
            width: parent.width
            placeholderText: "Text"
        }
        Button {
            id: updateText
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Update"
            onClicked: {
                const text = textField.text;
                if (text.length === 0)
                    return;
                textField.text = '';
                stringObject.updateValue(text);
                colorRectStr = text;
            }
        }
    }


}
