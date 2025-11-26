import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

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
