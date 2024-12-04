/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQml
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import "private" as P

/*!
  \qmltype ActionToolBar
  \inqmlmodule org.kde.kirigami

  \brief A toolbar built out of a list of actions.

  The default representation for visible actions is a QtQuick.Controls.ToolButton, but
  it can be changed by setting the Action.displayComponent for an action.
  The default behavior of ActionToolBar is to display as many actions as possible,
  placing those that will not fit into an overflow menu. This can be changed by
  setting the displayHint property on an Action. For example, when setting the
  DisplayHint.KeepVisible display hint, ActionToolBar will try to keep that action
  in view as long as possible, using an icon-only button if a button with text
  does not fit.

  \since 2.5
 */
QQC2.Control {
    id: root

//BEGIN properties
    /*!
      \qmlproperty list<Action> ActionToolBar::actions

      \brief This property holds a list of visible actions.

      The ActionToolBar will try to display as many actions as possible.
      Those that won't fit will go into an overflow menu.
     */
    readonly property alias actions: layout.actions

    /*!
      This property holds whether the buttons will have a flat appearance.

      default: \c true
     */
    property bool flat: true

    /*!
      This property determines how the icon and text are displayed within the button.

      Permitted values are:
      \list
      \li Button.IconOnly
      \li Button.TextOnly
      \li Button.TextBesideIcon
      \li Button.TextUnderIcon
      \endlist

      default: Controls.Button.TextBesideIcon

      \sa AbstractButton
     */
    property int display: QQC2.Button.TextBesideIcon

    /*!
      \qmlproperty Qt::Alignment ActionToolBar::alignment

      \brief This property holds the alignment of the buttons.

      When there is more space available than required by the visible delegates,
      we need to determine how to place the delegates.

      When there is more space available than required by the visible action delegates,
      we need to determine where to position them.

      default: Qt.AlignLeft

      \sa Qt::AlignmentFlag
     */
    property alias alignment: layout.alignment

    /*!
      \brief This property holds the position of the toolbar.

      If this ActionToolBar is the contentItem of a QQC2 Toolbar, the position is bound to the ToolBar's position

      Permitted values are:
      \list
      \li ToolBar.Header: The toolbar is at the top, as a window or page header.
      \li ToolBar.Footer: The toolbar is at the bottom, as a window or page footer.
      \endlist
     */
    property int position: parent instanceof T.ToolBar ? parent.position : QQC2.ToolBar.Header

    /*!
      \qmlproperty int ActionToolBar::maximumContentWidth

      \brief This property holds the maximum width of the content of this ToolBar.

      If the toolbar's width is larger than this value, empty space will
      be added on the sides, according to the Alignment property.

      The value of this property is derived from the ToolBar's actions and their properties.
     */
    readonly property alias maximumContentWidth: layout.implicitWidth

    /*!
      This property holds the name of the icon to use for the overflow menu button.

      default: "overflow-menu"

      \since 5.65
     */
    property string overflowIconName: "overflow-menu"

    /*!
       \qmlproperty int ActionToolbar::visibleWidth
       This property holds the combined width of all visible delegates.
     */
    readonly property alias visibleWidth: layout.visibleWidth

    /*!
      \qmlproperty enumeration ActionToolBar::heightMode

      \brief This property sets the handling method for items that do not match the toolbar's height.

      When toolbar items do not match the height of the toolbar, there are
      several ways we can deal with this. This property sets the preferred way.

      Permitted values are:
      \list
      \li HeightMode.AlwaysCenter
      \li HeightMode.AlwaysFill
      \li HeightMode.ConstrainIfLarger
      \endlist

      default: HeightMode::ConstrainIfLarger
     */
    property alias heightMode: layout.heightMode
//END properties

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    Layout.minimumWidth: layout.minimumWidth
    Layout.preferredWidth: 0
    Layout.fillWidth: true

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    contentItem: Kirigami.ToolBarLayout {
        id: layout
        spacing: Kirigami.Units.smallSpacing
        layoutDirection: root.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        fullDelegate: P.PrivateActionToolButton {
            flat: root.flat
            display: root.display
            action: Kirigami.ToolBarLayout.action
        }

        iconDelegate: P.PrivateActionToolButton {
            flat: root.flat
            display: QQC2.Button.IconOnly
            action: Kirigami.ToolBarLayout.action

            showMenuArrow: false

            menuActions: {
                if (action.displayComponent) {
                    return [action]
                }

                if (action instanceof Kirigami.Action) {
                    return action.children;
                }

                return []
            }
        }

        separatorDelegate: QQC2.ToolSeparator {}

        moreButton: P.PrivateActionToolButton {
            flat: root.flat
            Accessible.role: Accessible.ButtonMenu

            action: Kirigami.Action {
                tooltip: qsTr("More Actions")
                icon.name: root.overflowIconName
                displayHint: Kirigami.DisplayHint.IconOnly | Kirigami.DisplayHint.HideChildIndicator
            }

            Accessible.name: action.tooltip

            menuActions: root.actions

            menuComponent: P.ActionsMenu {
                submenuComponent: P.ActionsMenu {
                    Binding {
                        target: parentItem
                        property: "visible"
                        value: layout.hiddenActions.includes(parentAction)
                               && (!(parentAction instanceof Kirigami.Action) || parentAction.visible)
                        restoreMode: Binding.RestoreBinding
                    }

                    Binding {
                        target: parentItem
                        property: "autoExclusive"
                        value: action instanceof Kirigami.Action && action.autoExclusive
                        restoreMode: Binding.RestoreBinding
                    }
                }

                itemDelegate: P.ActionMenuItem {
                    visible: layout.hiddenActions.includes(action)
                             && (!(action instanceof Kirigami.Action) || action.visible)
                    autoExclusive: action instanceof Kirigami.Action && action.autoExclusive
                }

                loaderDelegate: Loader {
                    property T.Action action
                    height: visible ? implicitHeight : 0
                    visible: layout.hiddenActions.includes(action)
                             && (!(action instanceof Kirigami.Action) || action.visible)
                }

                separatorDelegate: QQC2.MenuSeparator {
                    property T.Action action
                    visible: layout.hiddenActions.includes(action)
                             && (!(action instanceof Kirigami.Action) || action.visible)
                }
            }
        }
    }
}
