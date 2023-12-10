import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3 as ListItem
import Lomiri.Components.Popups 1.3




// List
Item {
    signal listUpdated()
    signal contextTabReady(var reference)

    property Item headerReference
    property var totalHeaderHeight: headerReference.height + headerReference.extension.height

    Connections {
        target: root 
        onItemMovedToThings: {
            updateList();
        }
    }

    function updateList() {
        var data = databaseService.loadContexts(); 
        listModel.clear(); 
        for (var i = 0; i < data.length; i++) {
            listModel.append(data[i]); 
        }
    }

    function addContext(name) {
        databaseService.addContext(name);
    }

    Component.onCompleted: {
        contextTabReady(this);
    }

    Button {
        id: buttonCreate
        width: parent.width/2 
        height: units.gu(5)
        anchors {
            margins: units.gu(2)
            top: parent.top
            topMargin: totalHeaderHeight
            left: parent.left
            right: parent.right
        }
        text: "Create Context"
        onClicked: {
            var dialog = newContextDialog.createObject(root)
            if (dialog === null) {
                console.log("Error al crear el objeto del diálogo de confirmación")
                return;
            }
            dialog.visible = true
        }
    }

    LomiriListView {
        id: listContexts 
        width: parent.width
        height: units.gu(30)
        anchors {
            margins: units.gu(2)
            top: buttonCreate.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        model: ListModel {
            id: listModel
        }

        delegate: ListItemWithLabel {
            width: parent.width
            height: columnLayout.height
            color: dragging ? theme.palette.selected.base : "transparent"

            ColumnLayout {
                id: columnLayout
                width: parent.width
                spacing: units.gu(1)

                Text {
                    text: model.name
                    font.bold: true
                }
            }

            leadingActions: leadingActionsContext

            ListItemActions {
                id: leadingActionsContext

                actions: [
                    Action {
                        iconName: "delete"
                        onTriggered: {
                            var dialog = confirmDialogComponent.createObject(root, {"itemIndex": index})
                            if (dialog === null) {
                                console.log("Error al crear el objeto del diálogo de confirmación")
                                return;
                            }
                            dialog.visible = true
                        }
                    }
                ]
            }

            //divider {
            //    colorFrom: modelData == i18n.tr("Colored divider") ? LomiriColors.red : Qt.rgba(0.0, 0.0, 0.0, 0.0)
            //    colorTo: modelData == i18n.tr("Colored divider") ? LomiriColors.green : Qt.rgba(0.0, 0.0, 0.0, 0.0)
            //    visible: modelData != i18n.tr("No divider")
            //}
        }

        Component.onCompleted: {
            var data = databaseService.loadContexts();
            for (var i = 0; i < data.length; i++) {
                listModel.append(data[i]);
            }
        }
    }
    
    Component {
        id: confirmDialogComponent
        ConfirmDialog {
            id: confirmDialog
            property int itemIndex: -1

            title: "Eliminar thing"
            text: i18n.tr("Quieres eliminar completamente esta entrada?\n Ten en cuenta que sera eliminada de forma permanente")

            Row {
                id: row
                width: parent.width
                spacing: units.gu(1)
                Button {
                    width: parent.width/2 - row.spacing/2
                    text: "Cancel"
                    onClicked: PopupUtils.close(confirmDialog)
                }
                Button {
                    width: parent.width/2 - row.spacing/2
                    text: "Confirm"
                    color: LomiriColors.green
                    onClicked: {
                        if (itemIndex >= 0) {
                            console.log("Eliminar elemento con índice: " + itemIndex);
                            var id = listModel.get(itemIndex).id;
                            removeFromListModel(itemIndex);
                            removeActionableFromDatabase(id);
                        }
                        PopupUtils.close(confirmDialog)
                    }
                }
            }
        }
    }

    Component {
        id: newContextDialog
        ConfirmDialog {
            id: confirmDialog
            title: i18n.tr("Nuevo contexto")

            Column {
                spacing: units.gu(1)
                width: parent.width

                TextField {
                    width: parent.width
                    id: newContextInput
                    placeholderText: qsTr("Nombre del contexto")
                }
                Row {
                    id: row
                    width: parent.width
                    spacing: units.gu(1)
                    Button {
                        width: parent.width/2 - row.spacing/2
                        text: "Cancel"
                        onClicked: PopupUtils.close(confirmDialog)
                    }
                    Button {
                        width: parent.width/2 - row.spacing/2
                        text: "Confirm"
                        color: LomiriColors.green
                        onClicked: {
                            if (newContextInput.text != "") {
                                console.log("Agregando contexto");
                                addContext(newContextInput.text);
                                updateList();
                            }
                            PopupUtils.close(confirmDialog)
                        }
                    }
                }
            }
        }
    }
}
