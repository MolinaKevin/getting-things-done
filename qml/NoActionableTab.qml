import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3 as ListItem
import Lomiri.Components.Popups 1.3


// List
Item {
    signal listUpdated()
    signal noActionableTabReady(var reference)

    property Item headerReference
    property var totalHeaderHeight: headerReference.height + headerReference.extension.height

    Connections {
        target: root 
        onItemMovedToNoActionable: {
            updateList();
        }
    }

    function updateList() {
        var data = databaseService.loadNoActionable(); 
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

    function removeNoActionableFromDatabase(id) {
        databaseService.removeFromDatabase(id,'GtdNoActionable');
    }

    Component.onCompleted: {
        noActionableTabReady(this);
    }

    LomiriListView {
        id: listNoActionable
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
                }

                Text {
                    text: "Detalles: " + model.details
                }

                Text {
                    text: "Fecha de Revisión: " + model.reviewDate
                }

                Text {
                    text: "Categorias: " + model.category
                }
            }



            leadingActions: leadingActionsNoActionable
            trailingActions: trailingActionsNoActionable

            ListItemActions {
                id: trailingActionsNoActionable
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
                id: leadingActionsNoActionable

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
            var data = databaseService.loadNoActionable();
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
                            removeNoActionableFromDatabase(id);
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
                            toNoActionable(id);
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
