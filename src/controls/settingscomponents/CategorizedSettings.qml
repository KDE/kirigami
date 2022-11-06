/*
 *  SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 *  SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.11

/**
 * A container for setting actions showing them in a list view and displaying
 * the actual page next to it.
 *
 * @since 5.86
 * @since org.kde.kirigami 2.18
 * @inherit kde::org::kirigami::PageRow
 */
PageRow {
    id: pageSettingStack

    property list<PagePoolAction> actions
    property alias stack: pageSettingStack
    property PagePool pool: PagePool {}

    readonly property string title: pageSettingStack.depth < 2 ? qsTr("Settings") : qsTr("Settings — %1").arg(pageSettingStack.get(1).title)

    property bool completed: false

    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    topPadding: 0

    // With this, we get the longest word's width
    TextMetrics {
        id: maxWordMetrics
    }
    columnView.columnWidth: {
        if(!pageSettingStack.completed || actions.length === 0) {
            return Units.gridUnit * 6  // we return the min width if the component isn't completed
        }
        let longestWord = "";
        for (let i = 0; i < actions.length; i++) {
            const words = actions[i].text.split(" ");

            for (let j = 0; j < words.length; j++) {

                if (words[j].length > longestWord.length)
                    longestWord = words[j];
            }
        }
        // set the TextMetric's text to the longest word, to get the word's width.
        maxWordMetrics.text = longestWord;

        // fix words getting wrapped weirdly when the vertical scrollbar is shown
        const vScrollBarWidth = initialPage.contentItem.QQC2.ScrollBar.vertical.width;

        // we need to add spacing from ListView's item delegate and it's items
        const calcWidth = maxWordMetrics.width + Units.smallSpacing * 6 + vScrollBarWidth;
        const minWidth = Units.gridUnit * 6;
        const maxWidth = Units.gridUnit * 8.5;

        return Math.max(minWidth, Math.min(calcWidth, maxWidth));
    }
    globalToolBar.showNavigationButtons: ApplicationHeaderStyle.NoNavigationButtons
    globalToolBar.style: Settings.isMobile ? ApplicationHeaderStyle.Breadcrumb : ApplicationHeaderStyle.None

    signal backRequested(var event)
    onBackRequested: {
        if (pageSettingStack.depth > 1 && !pageSettingStack.wideMode && pageSettingStack.currentIndex !== 0) {
            event.accepted = true;
            pageSettingStack.pop();
        }
    }
    onWidthChanged: {
        if (pageSettingStack.depth < 2 && pageSettingStack.width >= Units.gridUnit * 40) {
            actions[0].trigger();
        }
    }

    initialPage: ScrollablePage {
        title: qsTr("Settings")
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        Theme.colorSet: Theme.View
        ListView {
            id: listview
            Component.onCompleted: if (pageSettingStack.width >= Units.gridUnit * 40) {
                actions[0].trigger();
            } else {
                if (count > 0) {
                    listview.currentIndex = 0;
                } else {
                    listview.currentIndex = -1;
                }
            }
            model: pageSettingStack.actions
            delegate: pageSettingStack.wideMode ? desktopStyle : mobileStyle
        }
    }

    Component {
        id: desktopStyle

        QQC2.ItemDelegate {
            width: parent && parent.width > 0 ? parent.width : implicitWidth
            implicitWidth: contentItem.implicitWidth + Units.smallSpacing * 4
            implicitHeight: contentItem.implicitHeight + Units.smallSpacing * 2

            action: modelData
            highlighted: listview.currentIndex === index
            onClicked: listview.currentIndex = index
            contentItem: ColumnLayout {
                spacing: Units.smallSpacing

                Icon {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Units.iconSizes.medium
                    Layout.preferredHeight: width
                    source: modelData.icon.name
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: Units.smallSpacing
                    Layout.rightMargin: Units.smallSpacing
                    text: modelData.text
                    wrapMode: Text.Wrap
                    color: highlighted ? Theme.highlightedTextColor : Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                }
            }

        }
    }

    Component {
        id: mobileStyle

        BasicListItem {
            action: modelData
            onClicked: {
                listview.currentIndex = index;
            }
        }
    }

    Component.onCompleted: {
        pageSettingStack.completed = true;
    }
}

