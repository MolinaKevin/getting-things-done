/*
 * Copyright (C) 2023  Molina Kevin
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * gtd is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'gtd.molinakevin'
    automaticOrientation: true

    signal itemMovedToThings(int id)
    signal itemMovedToNoActionable(int id)

    property var currentInboxTab: null

    width: units.gu(45)
    height: units.gu(75)


    DatabaseService {
        id: databaseService
    }

    Component.onCompleted: {
        databaseService.initializeDatabases();
    }

    StackView {
        id: stackView
        initialItem: initialPage
        anchors.fill: parent
    }

    Component {
        id: initialPage
        Page {
            anchors.fill: parent

            HeaderComponent {
                id: header
            }
            StackLayout {

                id: stackLayout
                anchors.fill: parent
                anchors.top: header.bottom

                ActionableTab {}
                InboxTab {
                    onInboxTabReady: {
                        currentInboxTab = reference;
                    }
                    onListUpdated: {
                        updateList();
                    }
                }
                NoActionableTab {}
            }
        }
    }
    // Botón flotante
    Button {
        id: floatingButton
        text: "+"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: units.gu(4)

        onClicked: {

            if (currentInboxTab) {
                var addItemPage = Qt.createComponent("AddItemPage.qml").createObject(stackView, {"inboxTabReference": currentInboxTab});
                stackView.push(addItemPage);
            }
        }
    }



}
