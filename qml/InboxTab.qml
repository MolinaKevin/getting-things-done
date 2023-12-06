import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3 as ListItem
import Lomiri.Components.Popups 1.3

// List
Item {
    signal listUpdated()
    signal inboxTabReady(var reference)

    property Item headerReference
    property var totalHeaderHeight: headerReference.height + headerReference.extension.height

    function updateList() {
        var data = databaseService.loadInbox(); 
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

    function removeInboxFromDatabase(id) {
        databaseService.removeFromDatabase(id,'GtdInbox');
    }

    function toNoActionable(id, details, reviewDate, category) {
        databaseService.moveItemToNoActionable(id, details, reviewDate, category);
        root.itemMovedToNoActionable(id);
    }

    function toActionable(id, details, dueDate, priority, status, context, project, tags) {
        databaseService.moveItemToActionable(id, details, dueDate, priority, status, context, project, tags);
        root.itemMovedToThings(id);
    }

    Component.onCompleted: {
        inboxTabReady(this);
    }

    LomiriListView {
        id: listInbox
        width: parent.width
        height: units.gu(30)
        anchors {
            margins: units.gu(2)
            //top: headerReference.bottom
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
                    text: "Estado: " + model.status
                }

                Text {
                    text: "Tags: " + model.tags
                }
                
                Text {
                    text: "Prioridad: " + model.priority
                }
            }

            leadingActions: leadingActionsInbox
            trailingActions: trailingActionsInbox

            ListItemActions {
                id: trailingActionsInbox
                actions: [
                    Action {
                        iconName: "note-new"
                        onTriggered: {
                            var currentItem = {
                                id: model.id, 
                                title: model.title,
                                details: model.details,
                                creationDate: model.creationDate,
                                source: model.source,
                                tags: model.tags,
                                status: model.status,
                                priority: model.priority
                            };
                            var dialog = actionableDialogComponent.createObject(root, {"itemIndex": index, "currentItem": currentItem})
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
                            var currentItem = {
                                id: model.id, 
                                title: model.title,
                                details: model.details,
                                creationDate: model.creationDate,
                                source: model.source,
                                tags: model.tags,
                                status: model.status,
                                priority: model.priority
                            };
                            var dialog = noActionableDialogComponent.createObject(root, {"itemIndex": index, "currentItem": currentItem})

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
                id: leadingActionsInbox
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
            //listInbox.anchors.top = header.bottom
            var data = databaseService.loadInbox();
            for (var i = 0; i < data.length; i++) {
                console.log(data[i].name);
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
                            removeInboxFromDatabase(id);
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
            property var currentItem: {}
            property string details: ""
            property string reviewDate: ""
            property string category: ""

            title: "No actionable Thing"
            text: i18n.tr("Convertir Thing en un no actionable?")

            Column {
                spacing: units.gu(1)
                width: parent.width

                TextField {
                    placeholderText: i18n.tr("Detalles")
                    text: currentItem.details 
                    onTextChanged: details = text
                }

                TextField {
                    placeholderText: i18n.tr("Fecha de revisión")
                    text: currentItem.reviewDate 
                    onTextChanged: reviewDate = text
                }

                TextField {
                    placeholderText: i18n.tr("Categoría")
                    text: currentItem.category
                    onTextChanged: category = text
                }
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
                        if (itemIndex >= 0) {
                            console.log("Eliminar elemento con índice: " + itemIndex);
                            var id = listModel.get(itemIndex).id;
                            toNoActionable(id, details, reviewDate, category);
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
            property var currentItem: {}
            property string details: ""
            property int itemIndex: -1
            property string dueDate
            property int priority
            property string status
            property string context
            property string project
            property string tags

            title: "Actionable Thing"
            text: i18n.tr("Convertir Thing en un actionable?")

            Column {
                spacing: units.gu(1)
                width: parent.width

                TextField {
                    id: detailsField 
                    placeholderText: qsTr("Detalles")
                    text: currentItem.details 
                    onTextChanged: details = text
                }

                TextField {
                    id: dueDateField
                    placeholderText: qsTr("Due Date")
                    onTextChanged: dueDate = text
                }

                TextField {
                    id: priorityField
                    text: currentItem.priority
                    onTextChanged: priority = text 
                }

                TextField {
                    id: statusField
                    text: currentItem.status
                    placeholderText: qsTr("Status")
                    onTextChanged: status = text
                }

                TextField {
                    id: contextField
                    placeholderText: qsTr("Context")
                    onTextChanged: context = text
                }

                TextField {
                    id: projectField
                    placeholderText: qsTr("Project")
                    onTextChanged: project = text
                }

                TextField {
                    id: tagsField
                    text: currentItem.tags
                    placeholderText: qsTr("Tags")
                    onTextChanged: tags = text
                }
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
                        if (itemIndex >= 0) {
                            console.log("Eliminar elemento con índice: " + itemIndex);
                            var id = listModel.get(itemIndex).id;
                            toActionable(id, details, dueDate, priority, status, context, project, tags);
                            removeFromListModel(itemIndex);
                        }
                        PopupUtils.close(confirmDialog)
                    }
                }
            }
        }
    }
}
