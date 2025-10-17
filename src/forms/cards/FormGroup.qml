import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string title
    default property alias entries: innerLayout.data
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Layout.fillWidth: true

    Kirigami.HeaderFooterLayout {
        id: layout
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing
        // TODO: HeaderFooterLayout needs headerMargin/footerMargin

        header: Kirigami.Heading {
            level: 5
            font.weight: Font.DemiBold
            visible: text.length > 0
            text: root.title
        }
        contentItem: Kirigami.AbstractCard {
            padding: 0
            contentItem: ColumnLayout {
                id: innerLayout
                spacing: 0
            }
        }
    }
}
