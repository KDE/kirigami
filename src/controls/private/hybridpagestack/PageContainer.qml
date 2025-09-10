/*
 *  SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */


import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    // The Kirigami PageStack
    property var pageStack

    // The page to put in the PageContainer
    property Kirigami.Page page

    // Whether to automatically destroy the given page when the container is destroyed.
    property bool autoDestroyPage

    readonly property bool showBackButton: root.QQC2.StackView.index > 0

    Component.onDestruction: {
        if (page && autoDestroyPage) {
            page.destroy();
        }
    }

    onPageChanged: {
        if (!page) {
            return;
        }
        page.parent = pageParent;
        page.anchors.fill = pageParent;
        page.visible = true;
    }

    ColumnLayout {
        spacing: 0
        anchors.fill: parent

        Loader {
            id: pageHeaderLoader
            active: root.page ? root.page.titleDelegate : false
            Layout.fillWidth: true

            sourceComponent: PageHeader {
                titleDelegate: root.page ? root.page.titleDelegate : null
                actions: root.page ? root.page.actions : []
                showBackButton: root.showBackButton
                pageStack: root.pageStack
            }
        }

        Item {
            id: pageParent
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
