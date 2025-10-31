import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

/*!
    \qmltype FormSeparator
    \inqmlmodule org.kde.kirigami.forms

    \brief Visual separator between form entries.

    When form entries in a group need to be visually separed, as a form of
    logical grouping, a FormSeparator instance will be placed in the FormGroup
    in between the FormEntry instances.

    \sa FormGroup
 */
Item {
    id: root

    Layout.fillWidth: true

    implicitWidth: separator.implicitWidth
    implicitHeight: separator.implicitHeight

    Kirigami.Separator {
        id: separator
        opacity: 0.5
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Kirigami.Units.largeSpacing
            rightMargin: Kirigami.Units.largeSpacing
        }
    }
}
