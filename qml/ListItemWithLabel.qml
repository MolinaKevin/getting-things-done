import QtQuick 2.4
import Lomiri.Components 1.3

ListItem {
    property alias title: layout.title
    property alias subtitle: layout.subtitle

    height: layout.height + (divider.visible ? divider.height : 0)
    onPressAndHold: selectMode = !selectMode

    ListItemLayout { 
        id: layout 
        //subtitle.text: subtitle
    }
}

