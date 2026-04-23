/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.controls as KC
import org.kde.kirigami.layouts as KL
import "private" as P

/*!
  \qmltype ActionToolBar
  \inqmlmodule org.kde.kirigami

  \brief A toolbar built from a list of actions.

  Creates a toolbar out of a list of \l actions. Each item is a
  QtQuick.Controls.ToolButton by default, but this can be overridden by setting
  the Action.displayComponent property on that item's Action.

  The default behavior of ActionToolBar is to display as many items as possible,
  placing the ones that don't fit into an overflow menu. You can control this
  behavior by setting the displayHint property on an item's Action. For example,
  when setting the DisplayHint.KeepVisible display hint, ActionToolBar will try
  to keep that action's item in view as long as possible, transforming it into
  an icon-only button if a button with an icon and text doesn't fit.

  \since 2.5
 */
QQC2.Control {
    id: root

//BEGIN properties
    /*!
      \qmlproperty list<Action> ActionToolBar::actions

      \brief This property holds a list of visible actions.

      The ActionToolBar will try to display as many actions as possible.
      The ones that don't fit will go into an overflow menu.
     */
    readonly property alias actions: layout.actions

    /*!
      This property holds whether the buttons will have a flat/ToolButton style
      appearance.

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

      default: \c Controls.Button.TextBesideIcon

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

      default: \c Qt.AlignLeft

      \sa Qt::AlignmentFlag
     */
    property alias alignment: layout.alignment

    /*!
      \brief This property holds the position of the toolbar.

      If this ActionToolBar is the contentItem of a QQC2 ToolBar, the position
      is automatically bound to the ToolBar's position.

      Permitted values are:
      \list
      \li ToolBar.Header: The toolbar is at the top, as a window or page header.
      \li ToolBar.Footer: The toolbar is at the bottom, as a window or page footer.
      \endlist

      default: \c QQC2.ToolBar.Header
     */
    property int position: (parent as T.ToolBar)?.position ?? QQC2.ToolBar.Header

    /*!
      \qmlproperty int ActionToolBar::maximumContentWidth

      \brief This property holds the maximum width of the content.

      If the ActionToolBar's width is larger than this value, empty space will
      be added on the sides, according to the Alignment property.

      The value of this property is derived from the ActionToolBar's actions and
      their properties.
     */
    readonly property alias maximumContentWidth: layout.implicitWidth

    /*!
      This property holds the name of the icon to use for the overflow menu button.

      default: \c overflow-menu

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

      \brief This property determines how to handle items that do not match
      the ActionToolBar's height.

      Permitted values are:
      \list
      \li HeightMode.AlwaysCenter
      \li HeightMode.AlwaysFill
      \li HeightMode.ConstrainIfLarger
      \endlist

      default: \c HeightMode::ConstrainIfLarger
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

    contentItem: KL.ToolBarLayout {
        id: layout
        spacing: Platform.Units.smallSpacing
        layoutDirection: root.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        fullDelegate: P.PrivateActionToolButton {
            flat: root.flat
            display: root.display
            position: root.position
            action: KL.ToolBarLayout.action as T.Action
        }

        iconDelegate: P.PrivateActionToolButton {
            flat: root.flat
            display: QQC2.Button.IconOnly
            position: root.position
            action: KL.ToolBarLayout.action as T.Action

            showMenuArrow: false

            menuActions: {
                const kAction = action as KC.Action
                if (kAction?.displayComponent) {
                    return [action]
                }

                if (kAction) {
                    return kAction.children;
                }

                return []
            }
        }

        separatorDelegate: QQC2.ToolSeparator {}

        moreButton: P.PrivateActionToolButton {
            flat: root.flat
            Accessible.role: Accessible.ButtonMenu
            position: root.position

            action: KC.Action {
                tooltip: qsTr("More Actions")
                icon.name: root.overflowIconName
                displayHint: KL.DisplayHint.IconOnly | KL.DisplayHint.HideChildIndicator
            }

            Accessible.name: (action as KC.Action).tooltip

            menuActions: root.actions

            menuComponent: P.ActionsMenu {
                y: root.position === QQC2.ToolBar.Footer ? -height : 0
                submenuComponent: P.ActionsMenu {
                    id: actionsMenu

                    Binding {
                        target: actionsMenu.parentItem
                        property: "visible"
                        value: layout.hiddenActions.includes(actionsMenu.parentAction)
                               && ((actionsMenu.parentAction as KC.Action)?.visible ?? true)
                        restoreMode: Binding.RestoreBinding
                    }

                    Binding {
                        target: actionsMenu.parentItem
                        property: "autoExclusive"
                        value: (action as KC.Action)?.autoExclusive ?? false
                        restoreMode: Binding.RestoreBinding
                    }
                }

                itemDelegate: P.ActionMenuItem {
                    visible: layout.hiddenActions.includes(action)
                             && ((action as KC.Action)?.visible ?? true)
                    autoExclusive: (action as KC.Action).autoExclusive ?? false
                }

                loaderDelegate: Loader {
                    property T.Action action
                    height: visible ? implicitHeight : 0
                    visible: layout.hiddenActions.includes(action)
                             && ((action as KC.Action)?.visible ?? true)
                }

                separatorDelegate: QQC2.MenuSeparator {
                    property T.Action action
                    visible: layout.hiddenActions.includes(action)
                             && ((action as KC.Action)?.visible ?? true)
                }
            }
        }
    }
}
