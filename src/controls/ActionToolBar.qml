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
 * \sa A toolbar built out of a list of actions.
 *
 * The default representation for visible actions is a QtQuick.Controls.ToolButton, but
 * it can be changed by setting the `Action.displayComponent` for an action.
 * The default behavior of ActionToolBar is to display as many actions as possible,
 * placing those that will not fit into an overflow menu. This can be changed by
 * setting the `displayHint` property on an Action. For example, when setting the
 * `DisplayHint.KeepVisible` display hint, ActionToolBar will try to keep that action
 * in view as long as possible, using an icon-only button if a button with text
 * does not fit.
 *
 * @inherit QtQuick.Controls.Control
 * \since Kirigami 2.5
 */
QQC2.Control {
    id: root

//BEGIN properties
    /*!
     * \sa This property holds a list of visible actions.
     *
     * The ActionToolBar will try to display as many actions as possible.
     * Those that won't fit will go into an overflow menu.
     *
     * @property list<Action> actions
     */
    readonly property alias actions: layout.actions

    /*!
     * \sa This property holds whether the buttons will have a flat appearance.
     *
     * default: ``true``
     */
    property bool flat: true

    /*!
     * \sa This property determines how the icon and text are displayed within the button.
     *
     * Permitted values are:
     * * ``Button.IconOnly``
     * * ``Button.TextOnly``
     * * ``Button.TextBesideIcon``
     * * ``Button.TextUnderIcon``
     *
     * default: ``Controls.Button.TextBesideIcon``
     *
     * \sa QtQuick.Controls.AbstractButton
     * @property int display
     */
    property int display: QQC2.Button.TextBesideIcon

    /*!
     * \sa This property holds the alignment of the buttons.
     *
     * When there is more space available than required by the visible delegates,
     * we need to determine how to place the delegates.
     *
     * When there is more space available than required by the visible action delegates,
     * we need to determine where to position them.
     *
     * default: ``Qt.AlignLeft``
     *
     * \sa Qt::AlignmentFlag
     * @property int alignment
     */
    property alias alignment: layout.alignment

    /*!
     * \sa This property holds the position of the toolbar.
     *
     * If this ActionToolBar is the contentItem of a QQC2 Toolbar, the position is bound to the ToolBar's position
     *
     * Permitted values are:
     * * ``ToolBar.Header``: The toolbar is at the top, as a window or page header.
     * * ``ToolBar.Footer``: The toolbar is at the bottom, as a window or page footer.
     *
     * @property int position
     */
    property int position: parent instanceof T.ToolBar ? parent.position : QQC2.ToolBar.Header

    /*!
     * \sa This property holds the maximum width of the content of this ToolBar.
     *
     * If the toolbar's width is larger than this value, empty space will
     * be added on the sides, according to the Alignment property.
     *
     * The value of this property is derived from the ToolBar's actions and their properties.
     *
     * @property int maximumContentWidth
     */
    readonly property alias maximumContentWidth: layout.implicitWidth

    /*!
     * \sa This property holds the name of the icon to use for the overflow menu button.
     *
     * default: ``"overflow-menu"``
     *
     * \since Kirigami 5.65
     * \since Kirigami 2.12
     */
    property string overflowIconName: "overflow-menu"

    /*!
     * \sa This property holds the combined width of all visible delegates.
     * @property int visibleWidth
     */
    readonly property alias visibleWidth: layout.visibleWidth

    /*!
     * \sa This property sets the handling method for items that do not match the toolbar's height.
     *
     * When toolbar items do not match the height of the toolbar, there are
     * several ways we can deal with this. This property sets the preferred way.
     *
     * Permitted values are:
     * * ``HeightMode.AlwaysCenter``
     * * ``HeightMode.AlwaysFill``
     * * ``AlwaysFill.ConstrainIfLarger``
     *
     * default: ``HeightMode::ConstrainIfLarger``
     *
     * \sa ToolBarLayout::heightMode
     * \sa ToolBarLayout::HeightMode
     * @property ToolBarLayout::HeightMode heightMode
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
                }

                itemDelegate: P.ActionMenuItem {
                    visible: layout.hiddenActions.includes(action)
                             && (!(action instanceof Kirigami.Action) || action.visible)
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
