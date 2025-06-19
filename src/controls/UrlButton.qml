/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.kirigami.private as KirigamiPrivate
import QtQuick.Controls as QQC2

/*!
  \qmltype UrlButton
  \inqmlmodule org.kde.kirigami
  \brief A link to a URL or other remote resource.

  UrlButton will open the URL when left-clicked, tapped, or activated with the
  keyboard. It will show a context menu with a "Copy" action when right-clicked.

  \since 5.63
 */
Kirigami.LinkButton {
    id: button

    /*!
      This property holds the URL to open when clicked or tapped.

      default: empty string; set a URL to make it work.
     */
    property string url

    /*!
       This property holds whether the URL is an external link.

       External links will have a small icon on their right to show that the
       link goes to an external website.

       default: \c true
       \since 6.11
     */
    property bool externalLink: true

    text: url
    enabled: url.length > 0
    visible: text.length > 0
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    Accessible.name: text
    Accessible.description: text !== url
        ? qsTr("Open link %1", "@info:whatsthis").arg(url)
        : qsTr("Open link", "@info:whatsthis")

    rightPadding: LayoutMirroring.enabled || !icon.visible ? 0 : icon.size + Kirigami.Units.smallSpacing
    leftPadding: LayoutMirroring.enabled && icon.visible ? icon.size + Kirigami.Units.smallSpacing : 0

    LayoutMirroring.childrenInherit: true

    Kirigami.Icon {
        id: icon

        readonly property int size: Kirigami.Units.iconSizes.sizeForLabels

        x: LayoutMirroring.enabled
            ? (button.width - button.contentWidth - size - Kirigami.Units.smallSpacing) / 2
            : (button.width + button.contentWidth + size + Kirigami.Units.smallSpacing) / 2 - size
        width: size
        height: size

        visible: button.externalLink && button.url.length > 0

        source: "open-link-symbolic"
        fallback: "link-symbolic"
        color: button.color

        anchors.verticalCenter: button.verticalCenter
    }

    onPressed: mouse => {
        if (mouse.button === Qt.RightButton) {
            menu.popup();
        }
    }

    onClicked: mouse => {
        if (mouse.button !== Qt.RightButton) {
            Qt.openUrlExternally(url);
        }
    }

    QQC2.ToolTip.visible: button.text !== button.url && button.url.length > 0 && button.mouseArea.containsMouse
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
    QQC2.ToolTip.text: button.url

    QQC2.Menu {
        id: menu
        QQC2.MenuItem {
            text: qsTr("Copy Link to Clipboard")
            icon.name: "edit-copy"
            onClicked: KirigamiPrivate.CopyHelperPrivate.copyTextToClipboard(button.url)
        }
    }
}
