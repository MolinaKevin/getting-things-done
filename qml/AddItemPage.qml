import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import Lomiri.Components.Pickers 1.0

Page {
    property var inboxTabReference: null

    anchors.fill: parent
    // Header. PageHeader didnt work
    header: ToolBar { 
        id: header
        contentHeight: textHeader.height
        width: parent.width

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
            topMargin: header.height + units.gu(4)
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            fill: parent
        }
        TextField {
            id: titleInput
            placeholderText: i18n.tr("Titulo")
            width: parent.width - 20
            height: units.gu(5)
        }

        TextField {
            id: dateInput
            width: parent.width - 20
            placeholderText: i18n.tr("Fecha")
            height: units.gu(5)
            readOnly: true  

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    datePickerDialog.open()
                }
            }
        }

        Dialog {
            id: datePickerDialog
            modal: true
            contentItem: Column {
                Label {
                    text: "Selected date: " +
                            Qt.formatDate(datePicker.date, "dddd, dd-MMMM-yyyy") + " " + Qt.formatTime(timePicker.date, "hh:mm")
                }
                DatePicker {
                    id: datePicker
                    mode: "Years|Months|Days"
                }
                DatePicker {
                    id: timePicker
                    mode: "Hours|Minutes"
                }
                Button {
                    text: i18n.tr("Confirmar")
                    onClicked: {
                        var selectedDate = Qt.formatDate(datePicker.date, "dd-MM-yyyy");
                        var selectedTime = Qt.formatTime(timePicker.date, "HH:mm");
                        dateInput.text = selectedDate + " " + selectedTime;
                        datePickerDialog.close();
                    }
                }

                Button {
                    text: i18n.tr("Cancelar")
                    onClicked: {
                        datePickerDialog.close();
                    }
                }
            }          
        }

        TextField {
            id: detailsInput 
            width: parent.width - 20
            placeholderText: i18n.tr("Detalles")
            height: units.gu(5)
        }

        TextField {
            id: sourceInput 
            width: parent.width - 20
            placeholderText: i18n.tr("Fuente (Source)")
            height: units.gu(5)
        }

        TextField {
            id: tagsInput 
            width: parent.width - 20
            placeholderText: i18n.tr("Tags")
            height: units.gu(5)
        }

        TextField {
            id: statusInput 
            width: parent.width - 20
            placeholderText: i18n.tr("Estado")
            height: units.gu(5)
        }

        TextField {
            id: priorityInput
            width: parent.width - 20
            placeholderText: i18n.tr("Prioridad")
            height: units.gu(5)
            inputMethodHints: Qt.ImhDigitsOnly
        }

        Button {
            text: i18n.tr("Agregar")
            onClicked: {
                databaseService.addDataInbox(titleInput.text, dateInput.text, detailsInput.text, sourceInput.text, tagsInput.text, statusInput.text, priorityInput.text);
                if (inboxTabReference) {
                    inboxTabReference.listUpdated();
                }
                stackView.pop()
            }
        }

        Button {
            text: i18n.tr("Cancelar")
            onClicked: {
                if (inboxTabReference) {
                    inboxTabReference.listUpdated();
                }
                stackView.pop()
            }
        }


    }
}

