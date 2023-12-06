import QtQuick 2.7
import Lomiri.Components 1.3

PageHeader {
    id: header
    title: i18n.tr('Getting Things Done')

    extension: Sections {
        width: parent.width

        actions: [
            Action {
                text: "Actionable"
                onTriggered: { stackLayout.currentIndex = 0; }
            },
            Action {
                text: "Inbox"
                onTriggered: { stackLayout.currentIndex = 1; }
            },
            Action {
                text: "No Actionable"
                onTriggered: { stackLayout.currentIndex = 2; }
            }
        ]
    }
}
