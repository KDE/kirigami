/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami


/*!
    \qmltype Form
    \inqmlmodule org.kde.kirigami.forms

    \brief The base class for Form layouts conforming to the
    Kirigami Human Interface Guidelines.

    The base class for doing forms in Kirigami, for example settings page.
    The look and feel of the forms is dictated by the Human Interface Guidelines
    and is subject to change, while the API is expected to stay the same
    for the foreseeable future.

    A Form layout is meant to contain a set of FormGroup that separe the form in
    various logical sections, and each FormGroup will contain a set of FormEntry

    This is meant to replace the FormLayout class.

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
        }
        KF.FormGroup {
            title: i18n("Other settings")
            KF.FormEntry {
                contentItem: QQC.CheckBox {
                    text: i18n("Double Click")
                }
            }
        }
    }
    \endqml
  */
Item {
    id: root
    default property alias entries: layout.data
    Accessible.role: Accessible.Form

    implicitWidth: layout.implicitWidth + Kirigami.Units.largeSpacing * 2
    implicitHeight: layout.implicitHeight + Kirigami.Units.largeSpacing * 2

    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing
        width: Math.min(implicitWidth, parent.width, Kirigami.Units.gridUnit * 32)
    }
}
