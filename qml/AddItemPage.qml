import QtQuick 2.7
import QtQuick.Controls 2.2

Page {
    property var inboxTabReference: null

    anchors.fill: parent
    // Header. PageHeader didnt work
    header: ToolBar { 
        id: header
        contentHeight: textHeader.height

        Label {
            id: textHeader
            text: qsTr("Add new Thing")
            anchors.centerIn: parent
        }
    }


    DatabaseService {
        id: databaseService
    }

    Column {
        spacing: 10
        anchors.centerIn: parent

        anchors {
            margins: units.gu(2)
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            fill: parent
        }
        TextField {
            id: titleInput
            placeholderText: i18n.tr("Titulo")
            width: parent.width - 20
            height: 50
        }

        TextField {
            id: dateInput
            width: parent.width - 20
            placeholderText: i18n.tr("Fecha")
            height: 50

            text: Qt.formatDateTime(new Date(), "dd-MM-yyyy HH:mm") 
        }

        TextField {
            id: detailsInput 
            width: parent.width - 20
            placeholderText: i18n.tr("Detalles")
            height: 50
        }

        TextField {
            id: sourceInput 
            width: parent.width - 20
            placeholderText: i18n.tr("Fuente (Source)")
            height: 50
        }

        TextField {
            id: tagsInput 
            width: parent.width - 20
            placeholderText: i18n.tr("Tags")
            height: 50
        }

        TextField {
            id: statusInput 
            width: parent.width - 20
            placeholderText: i18n.tr("Estado")
            height: 50
        }

        TextField {
            id: priorityInput
            width: parent.width - 20
            placeholderText: i18n.tr("Prioridad")
            height: 50
        }

        Button {
            text: "Agregar"
            onClicked: {
                databaseService.addDataInbox(titleInput.text, dateInput.text, detailsInput.text, sourceInput.text, tagsInput.text, statusInput.text, priorityInput.text);
                if (inboxTabReference) {
                    inboxTabReference.listUpdated();
                }
                stackView.pop()
            }
        }
    }
}

