/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import "private" as P

/*!
  \qmltype Card
  \inqmlmodule org.kde.kirigami

  \brief This is the standard layout of a Card.

  It is recommended to use this class when the concept of Cards is needed
  in the application.

  This Card has default items as header and footer. The header is an
  image that can contain an optional title and icon, accessible via the
  banner grouped property.

  The footer will show a series of toolbuttons (and eventual overflow menu)
  representing the actions list accessible with the list property actions.
  It is possible even tough is discouraged to override the footer:
  in this case the actions property shouldn't be used.

  \since 2.4
 */
Kirigami.AbstractCard {
    id: root

    /*!
      \brief This property holds the clickable actions that will be available in the footer
      of the card.

      The actions will be represented by a list of ToolButtons with an optional overflow
      menu, when not all of them will fit in the available Card width.

     */
    property list<T.Action> actions

    /*!
      \qmlproperty url Card::banner.source
      \qmlproperty string Card::banner.titleIcon
      \qmlproperty string Card::banner.title
      \qmlproperty Qt.Alignment Card::banner.titleAlignment
      \qmlproperty int Card::banner.titleLevel
      \qmlproperty QtQuick.Text.wrapMode Card::banner.titleWrapMode

      \brief This grouped property controls the banner image present in the header.

      It also has the full set of properties that QtQuick.Image has, such as sourceSize and fillMode.

      \list
      \li source: The source for the image. It understands any URL valid for an Image component.
      \li titleIcon: The optional icon to put in the banner, either a freedesktop-compatible
      icon name (recommended) or any URL supported by QtQuick.Image.
      \li title: The title for the banner, shown as contrasting text over the image.
      \li titleAlignment: The alignment of the title inside the image. Default: \c {Qt.AlignTop | Qt.AlignLeft}.
      \li titleLevel: The Kirigami.Heading level for the title, ranging from 1 (big) to 5 (small). Default: \c 1.
      \li titleWrapMode: Whether the header text should be able to wrap. Default: \c Text.NoWrap.
      \endlist

     */
    readonly property alias banner: bannerImage

    Accessible.name: banner.title

    header: Kirigami.Padding {
        topPadding: -root.topPadding + root.background.border.width
        leftPadding: -root.leftPadding + root.background.border.width
        rightPadding: -root.rightPadding + root.background.border.width
        bottomPadding: root.contentItem ? 0 : -root.bottomPadding + root.background.border.width

        contentItem: P.BannerImage {
            id: bannerImage

            implicitWidth: Layout.preferredWidth
            implicitHeight: (source.toString().length > 0 && sourceSize.width > 0 && sourceSize.height > 0 ? width / (sourceSize.width / sourceSize.height) : Layout.minimumHeight) + parent.topPadding + parent.bottomPadding

            readonly property real widthWithBorder: width + root.background.border.width * 2
            readonly property real heightWithBorder: height + root.background.border.width * 2
            readonly property real radiusFromBackground: root.background.radius - root.background.border.width

            corners.topLeftRadius: radiusFromBackground
            corners.topRightRadius: radiusFromBackground
            corners.bottomLeftRadius: radiusFromBackground
            corners.bottomRightRadius: heightWithBorder < root.height ? 0 : radiusFromBackground

            checkable: root.checkable
            checked: root.checkable && root.checked

            onToggled: checked => {
                root.checked = checked;
                root.toggled(checked);
            }
        }
    }

    onHeaderChanged: {
        if (!header) {
            return;
        }

        header.anchors.topMargin = Qt.binding(() => -root.topPadding);
        header.anchors.leftMargin = Qt.binding(() => -root.leftPadding);
        header.anchors.rightMargin = Qt.binding(() => -root.rightPadding);
        header.anchors.bottomMargin = Qt.binding(() => 0);
    }

    footer: Kirigami.ActionToolBar {
        id: actionsToolBar
        actions: root.actions
        position: QQC2.ToolBar.Footer
    }
}
