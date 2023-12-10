import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3 as ListItem
import Lomiri.Components.Popups 1.3




// List
Item {
    signal listUpdated()
    signal actionableTabReady(var reference)

    property Item headerReference
    property var totalHeaderHeight: headerReference.height + headerReference.extension.height

    Connections {
        target: root 
        onItemMovedToThings: {
            updateList();
        }
    }

    function updateList() {
        var data = databaseService.loadActionable(); 
        listModel.clear(); 
        for (var i = 0; i < data.length; i++) {
            listModel.append(data[i]); 
        }
    }

    function removeFromListModel(index) {
        if (index >= 0 && index < listModel.count) {
            listModel.remove(index);
        }
    }

    function removeActionableFromDatabase(id) {
        databaseService.removeFromDatabase(id,'GtdThings');
    }

    Component.onCompleted: {
        actionableTabReady(this);
    }

    LomiriListView {
        id: listActionable
        width: parent.width
        height: units.gu(30)
        anchors {
            margins: units.gu(2)
            top: parent.top
            topMargin: totalHeaderHeight
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        model: ListModel {
            id: listModel
            //ListElement {
            //    title: "Some Name"
            //    creationDate: "Some Date"
            //}
        }

        delegate: ListItemWithLabel {
            //title.text: model.title 
            //subtitle.text: model.creationDate
            width: parent.width
            height: columnLayout.height
            color: dragging ? theme.palette.selected.base : "transparent"

            ColumnLayout {
                id: columnLayout
                width: parent.width
                spacing: units.gu(1)

                Text {
                    text: model.title
                    font.bold: true
                }

                Text {
                    text: "Fecha de creación: " + model.creationDate
                    visible: model.creationDate !== undefined && model.creationDate !== ""
                }

                Text {
                    text: "Detalles: " + model.details
                    visible: model.details !== undefined && model.details !== ""
                }

                Text {
                    text: "Fecha de vencimiento: " + model.dueDate
                    visible: model.dueDate !== undefined && model.dueDate !== ""
                }

                Text {
                    text: "Estado: " + model.status
                    visible: model.status !== undefined && model.status !== ""
                }

                Text {
                    text: "Contexto: " + model.contextName
                    visible: model.contextName !== undefined && model.contextName !== ""
                }

                Text {
                    text: "Proyecto: " + model.projectName
                    visible: model.projectName !== undefined && model.projectName !== ""
                }

                Text {
                    text: "Tags: " + model.tags
                    visible: model.tags !== undefined && model.tags !== ""
                }

            }

            leadingActions: leadingActionsActionable
            trailingActions: trailingActionsActionable

            ListItemActions {
                id: trailingActionsActionable
                actions: [
                    Action {
                        iconName: "note-new"
                        onTriggered: {
                            var dialog = actionableDialogComponent.createObject(root, {"itemIndex": index})
                            if (dialog === null) {
                                console.log("Error al crear el objeto del diálogo de confirmación")
                                return;
                            }
                            dialog.visible = true
                        }
                    },
                    Action {
                        iconName: "new-message"
                        onTriggered: {
                            var dialog = noActionableDialogComponent.createObject(root, {"itemIndex": index})
                            if (dialog === null) {
                                console.log("Error al crear el objeto del diálogo de confirmación")
                                return;
                            }
                            dialog.visible = true
                        }
                    }
                ]
            }

            ListItemActions {
                id: leadingActionsActionable

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
            var data = databaseService.loadActionable();
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
        id: noActionableDialogComponent
        ConfirmDialog {
            id: confirmDialog
            property int itemIndex: -1

            title: "No actionable Thing"
            text: i18n.tr("Convertir Thing en un no actionable?")

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
                            toActionable(id);
                            removeFromListModel(itemIndex);
                        }
                        PopupUtils.close(confirmDialog)
                    }
                }
            }
        }
    }
    Component {
        id: actionableDialogComponent
        ConfirmDialog {
            id: confirmDialog
            property int itemIndex: -1

            title: "Actionable Thing"
            text: i18n.tr("Convertir Thing en un actionable?")

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
                            toActionable(id);
                            removeFromListModel(itemIndex);
                        }
                        PopupUtils.close(confirmDialog)
                    }
                }
            }
        }
    }
}
