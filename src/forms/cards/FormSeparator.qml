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

    Example usage:

    \qml
    import QtQuick.Controls as QQC
    import org.kde.kirigami.forms as KF

    KF.Form {
        KF.FormGroup {
            title: i18n("Section1")
            KF.FormEntry {
                title: i18n("Name:")
                contentItem: QQC.TextField {}
            }
            KF.FormEntry {
                title: i18n("Notifications:")
                subtitle: i18n("Notifications will pop up when a message arrives.")
                contentItem: QQC.CheckBox {
                    text: i18n("Enabled")
                }
            }
            KF.FormSeparator {}
            KF.FormEntry {
                title: i18n("Last Name:")
                contentItem: QQC.TextField {}
            }
        }
    \endqml

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
