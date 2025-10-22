import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

Item {
    id: root

    Layout.fillWidth: true

    property string title
    default property alias entries: innerLayout.data
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight //+ layout.y

    readonly property real __maxTextLabelWidth: innerLayout.labelWidth
    property alias __assignedWidthForLabels: innerLayout.__assignedWidthForLabels

    Kirigami.HeaderFooterLayout {
        id: layout
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        header: Kirigami.Heading {
            level: 5
            font.weight: Font.DemiBold
            visible: text.length > 0
            text: root.title
        }
        contentItem: Kirigami.AbstractCard {
            padding: 0
            implicitWidth: innerLayout.implicitWidth + __assignedWidthForLabels//+ innerLayout.labelWidth
           // leftPadding: root.parent.parent.__collapsed ? padding : root.__assignedWidthForLabels + padding
            contentItem: ColumnLayout {
                id: innerLayout
                property real labelWidth: 0
                property real __assignedWidthForLabels: 0
                onImplicitWidthChanged: {
                    let w = 0;
                    for (let entry of children) {
                        w = Math.max(w, entry?.__textLabelWidth ?? 0);
                    }
                    labelWidth = w;
                }
                spacing: 0
            }
        }
    }
}
