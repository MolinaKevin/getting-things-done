import QtQuick 2.7
import Lomiri.Components 1.3

PageHeader {
    id: header
    title: i18n.tr('Getting Things Done')
    subtitle: i18n.tr("Swip left or right in items for actions")

    extension: Sections {
        width: parent.width

        actions: [
            Action {
                text: i18n.tr("Actionable")
                onTriggered: { stackLayout.currentIndex = 0; }
            },
            Action {
                text: i18n.tr("Inbox")
                onTriggered: { stackLayout.currentIndex = 1; }
            },
            Action {
                text: i18n.tr("No Actionable")
                onTriggered: { stackLayout.currentIndex = 2; }
            },
            Action {
                text: i18n.tr("Contextos")
                onTriggered: { stackLayout.currentIndex = 3; }
            },
            Action {
                text: i18n.tr("Proyectos")
                onTriggered: { stackLayout.currentIndex = 4; }
            }


        ]
    }
}
