/*
 * SPDX-FileCopyrightText: 2023 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami.platform as Platform

/*!
  \qmltype SwitchSubtitleDelegate
  \inqmlmodule org.kde.kirigami.delegates

  \brief A convenience wrapper combining QtQuick Controls SwitchDelegate and IconTitleSubtitle.

  This is an intentionally minimal wrapper that replaces the SwitchDelegate's
  contentItem with an IconTitleSubtitle and adds a subtitle property.

  If you wish to customize the layout further, create your own SwitchDelegate
  subclass with the \c contentItem: property set to the content of your choice.
  This can include IconTitleSubtitle inside a Layout, for example.

  \note If you don't need a subtitle, use SwitchDelegate directly.

  \sa TitleSubtitle
  \sa IconTitleSubtitle
 */
QQC2.SwitchDelegate {
    id: delegate

    // Please see the developer note in ItemDelegate

    /*!
      The subtitle to display.
     */
    property string subtitle

    QQC2.ToolTip.text: text + (subtitle.length > 0 ? "\n\n" + subtitle : "")
    QQC2.ToolTip.visible: (Platform.Settings.tabletMode ? down : hovered) && (contentItem?.truncated ?? false)
    QQC2.ToolTip.delay: Platform.Units.toolTipDelay

    contentItem: IconTitleSubtitle {
        icon: icon.fromControlsIcon(delegate.icon)
        title: delegate.text
        subtitle: delegate.subtitle
        selected: delegate.highlighted || delegate.down
        font: delegate.font
    }
}
