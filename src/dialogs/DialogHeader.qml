/*
 SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>
 SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.kirigami.dialogs as KDialogs

/*!
  \qmltype DialogHeader
  \inqmlmodule org.kde.kirigami.dialogs

  \brief Base for a header, to be used as the header: item of a Dialog.

  Provides appropriate padding and a bottom separator when the dialog's content
  is scrollable.

  Chiefly useful as the base element of a custom header. Example usage for this:

  \qml
  import QtQuick
  import org.kde.kirigami as Kirigami
  import org.kde.kirigami.dialogs as KD

  Kirigami.Dialog {
      id: myDialog

      title: i18n("My Dialog")

      standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

      header: KDialogs.DialogHeader {
          dialog: myDialog
          contentItem: [...]
      }
      [...]
  }
  \endqml
 */
T.Control {
    id: root

    /*!
      \qmlproperty Dialog DialogHeader::dialog
      This property points to the parent dialog, some of whose properties
      need to be available here.
     */
    required property T.Dialog dialog

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: Kirigami.Units.largeSpacing
    bottomPadding: verticalPadding + headerSeparator.implicitHeight // add space for bottom separator

    // Bottom separator shown when content is scrollable
    background: Item {
        Kirigami.Separator {
            id: headerSeparator
            width: parent.width
            anchors.bottom: parent.bottom
            visible: if (root.dialog.contentItem instanceof T.Pane || root.dialog.contentItem instanceof Flickable) {
                return root.dialog.contentItem.contentHeight > root.dialog.implicitContentHeight;
            } else {
                return false;
            }
        }
    }

    contentItem: KDialogs.DialogHeaderTopContent {
        dialog: root.dialog
    }
}
