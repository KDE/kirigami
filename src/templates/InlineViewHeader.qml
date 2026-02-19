/*
 *  SPDX-FileCopyrightText: 2023 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2026 Akseli Lahtinen <akselmo@akselmo.dev>
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T

/*!
 *  \qmltype InlineViewHeader
 *  \inqmlmodule org.kde.kirigami
 *
 *  \brief A fancy inline view header showing a title and optional actions.
 *
 *  Designed to be set as the header: property of a ListView or GridView, this
 *  component provides a fancy inline header suitable for explaining the contents
 *  of its view to the user in an attractive and standardized way.
 *
 *  Actions globally relevant to the view can be defined using the \l actions property.
 *  They will appear on the trailing side of the header as buttons, and collapse
 *  into an overflow menu when there isn't room to show them all.
 *
 *  The \l width property must be manually set to the parent view's width.
 *
 *  Example usage:
 *  \code
 *  import org.kde.kirigami as Kirigami
 *
 *  ListView {
 *      id: listView
 *
 *      headerPositioning: ListView.OverlayHeader
 *      header: InlineViewHeader {
 *          width: listView.width
 *          text: "My amazing view"
 *          actions: [
 *              Kirigami.Action {
 *                  icon.name: "list-add-symbolic"
 *                  text: "Add item"
 *                  onTriggered: {
 *                      // do stuff
 *                  }
 *              }
 *          ]
 *      }
 *
 *      model: [...]
 *      delegate: [...]
 *  }
 *  \endcode
 */
T.ToolBar {
	id: root

	//BEGIN properties
	/*!
	 *      \brief This property holds the title text.
	 */
	property string text

	/*!
	 *      \qmlproperty list<Action> InlineViewHeader::actions
	 *
	 *      This property holds the list of actions to show on the header. Actions
	 *      are added from left to right. If more actions are set than can fit, an
	 *      overflow menu is provided.
	 */
	property list<T.Action> actions
	//END properties

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
}
