import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    width: 600
    height: 275

    Kirigami.FormLayout {
        anchors.fill: parent

        Kirigami.ColoredBadgeLabel {
            Kirigami.FormData.label: "Compact, short string, default background color:"
            text: "New!"
            compact: true
        }

        Kirigami.ColoredBadgeLabel {
            Kirigami.FormData.label: "Large, short string, positive background color:"
            text: "New!"
            backgroundColor: Kirigami.Theme.positiveBackgroundColor
        }

        Kirigami.ColoredBadgeLabel {
            Kirigami.FormData.label: "Compact, long string, bounded, neutral background color:"
            Layout.maximumWidth: 150
            text: "New is really just a state of mind; what can we even say about this?"
            backgroundColor: Kirigami.Theme.neutralBackgroundColor
            compact: true
        }

        Kirigami.ColoredBadgeLabel {
            Kirigami.FormData.label: "Large, short string, bounded, negative background color:"
            Layout.maximumWidth: 150
            text: "New is the opposite of old and has a definite meaning, so we can indeed say something specific about it"
            backgroundColor: Kirigami.Theme.negativeBackgroundColor
        }
    }
}
