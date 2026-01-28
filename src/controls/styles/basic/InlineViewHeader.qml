/*
 *  SPDX-FileCopyrightText: 2023 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives

/*!
  \qmltype InlineViewHeader
  \inqmlmodule org.kde.kirigami

  \brief A fancy inline view header showing a title and optional actions.

  Designed to be set as the header: property of a ListView or GridView, this
  component provides a fancy inline header suitable for explaining the contents
  of its view to the user in an attractive and standardized way.

  Actions globally relevant to the view can be defined using the \l actions property.
  They will appear on the trailing side of the header as buttons, and collapse
  into an overflow menu when there isn't room to show them all.

  The \l width property must be manually set to the parent view's width.

  Example usage:
  \code
  import org.kde.kirigami as Kirigami

  ListView {
      id: listView

      headerPositioning: ListView.OverlayHeader
      header: InlineViewHeader {
          width: listView.width
          text: "My amazing view"
          actions: [
              Kirigami.Action {
                  icon.name: "list-add-symbolic"
                  text: "Add item"
                  onTriggered: {
                      // do stuff
                  }
              }
          ]
      }

      model: [...]
      delegate: [...]
  }
  \endcode
 */
T.ToolBar {
    id: root

//BEGIN properties
    /*!
      \brief This property holds the title text.
     */
    property string text

    /*!
      \qmlproperty list<Action> InlineViewHeader::actions

      This property holds the list of actions to show on the header. Actions
      are added from left to right. If more actions are set than can fit, an
      overflow menu is provided.
     */
    property list<T.Action> actions
//END properties

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            Math.ceil(label.implicitWidth)
                            + rowLayout.spacing
                            + Math.ceil(Math.max(buttonsLoader.implicitWidth, buttonsLoader.Layout.minimumWidth))
                            + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    topPadding: Platform.Units.smallSpacing + (root.position === T.ToolBar.Footer ? separator.implicitHeight : 0)
    leftPadding: Platform.Units.largeSpacing
    rightPadding: Platform.Units.smallSpacing
    bottomPadding: Platform.Units.smallSpacing + (root.position === T.ToolBar.Header ? separator.implicitHeight : 0)

    z: 999 // don't let content overlap it

    // HACK Due to the lack of a GridView.headerPositioning property,
    // we need to "stick" ourselves to the top manually by translating Y accordingly.
    // see see https://bugreports.qt.io/browse/QTBUG-117035.
    // Conveniently, GridView is only attached to the root of the delegate (or headerItem),
    // so this will only be done if the InlineViewHeader itself is the header item.
    // And of course it won't be there for ListView either, where we have headerPositioning.
    transform: Translate {
        y: root.GridView.view ? root.GridView.view.contentY + root.height : 0
    }

    background: Rectangle {
        Platform.Theme.colorSet: Platform.Theme.View
        Platform.Theme.inherit: false
        // We want a color that's basically halfway between the view background
        // color and the window background color. But due to the use of color
        // scopes, only one will be available at a time. So to get basically the
        // same thing, we blend the view background color with a smidgen of the
        // text color.
        color: Qt.tint(Platform.Theme.backgroundColor, Qt.alpha(Platform.Theme.textColor, 0.03))

        Primitives.Separator {
            id: separator

            anchors {
                top: root.position === T.ToolBar.Footer ? parent.top : undefined
                left: parent.left
                right: parent.right
                bottom: root.position === T.ToolBar.Header ? parent.bottom : undefined
            }
        }
    }

    contentItem: RowLayout {
        id: rowLayout

        spacing: 0

        KC.Heading {
            id: label

            Layout.fillWidth: !buttonsLoader.active
            Layout.maximumWidth: {
                if (!buttonsLoader.active) {
                    return -1;
                }
                return rowLayout.width
                    - rowLayout.spacing
                    - buttonsLoader.Layout.minimumWidth;
            }
            Layout.alignment: Qt.AlignVCenter
            level: 2
            text: root.text
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }

        Loader {
            id: buttonsLoader

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.minimumWidth: (item as Item)?.Layout.minimumWidth ?? 0
            active: root.actions.length > 0
            sourceComponent: KC.ActionToolBar {
                actions: root.actions
                alignment: Qt.AlignRight
            }
        }
    }
}
