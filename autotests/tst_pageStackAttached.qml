/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import QtTest
import org.kde.kirigami as Kirigami

TestCase {
    id: testCase
    name: "PageStackAttachedTest"

    width: 400
    height: 400
    visible: true

    when: windowShown

    Kirigami.ApplicationWindow {
        id: mainWindow
        width: 480
        height: 360
    }

    Component {
        id: samplePage
        Kirigami.Page {
            property Item outerStack: Kirigami.PageStack.pageStack
            property alias innerRect: rect
            Rectangle {
                id: rect
                anchors.fill: parent
                color: "green"
                property Item stackFromChild: Kirigami.PageStack.pageStack
            }
        }
    }

    Component {
        id: pageWithInnerStack
        Kirigami.Page {
            property Item stack: Kirigami.PageStack.pageStack
            property alias subStack: stackView
            QQC.StackView {
                id: stackView
                anchors.fill: parent
            }
        }
    }

    Component {
        id: pageInLayer
        Kirigami.Page {
            property Item outerStack: Kirigami.PageStack.pageStack
            property alias innerRect: rect
            Rectangle {
                id: rect
                anchors.fill: parent
                color: "blue"
                property Item stackFromChild: Kirigami.PageStack.pageStack
            }
        }
    }

    SignalSpy {
        id: spyStackChanged
        signalName: "pageStackChanged"
    }


    function initTestCase(): void {
        mainWindow.show()
    }

    function cleanupTestCase(): void {
        mainWindow.close()
    }

    function init(): void {
        mainWindow.pageStack.clear()
        spyStackChanged.clear()
    }

    function test_accessPageRow(): void {
        compare(mainWindow.pageStack.depth, 0)
        mainWindow.pageStack.push(samplePage)
        compare(mainWindow.pageStack.depth, 1)

        let pageRowFirstPage = mainWindow.pageStack.items[0]

        compare(pageRowFirstPage.outerStack, mainWindow.pageStack)
        compare(pageRowFirstPage.innerRect.stackFromChild, mainWindow.pageStack)
    }

    function test_accessInnerStack(): void {
        compare(mainWindow.pageStack.depth, 0)
        mainWindow.pageStack.push(pageWithInnerStack)
        compare(mainWindow.pageStack.depth, 1)

        let pageRowFirstPage = mainWindow.pageStack.items[0]
        compare(pageRowFirstPage.stack, mainWindow.pageStack)

        pageRowFirstPage.subStack.push(samplePage)

        compare(pageRowFirstPage.subStack.currentItem.outerStack, pageRowFirstPage.subStack)
        compare(pageRowFirstPage.subStack.currentItem.innerRect.stackFromChild, pageRowFirstPage.subStack)
    }

    function test_accessLayersStack(): void {
        compare(mainWindow.pageStack.depth, 0)
        mainWindow.pageStack.push(samplePage)
        compare(mainWindow.pageStack.depth, 1)

        mainWindow.pageStack.layers.push(pageInLayer)

        let pageRowFirstPage = mainWindow.pageStack.items[0]
        compare(pageRowFirstPage.outerStack, mainWindow.pageStack)
        compare(pageRowFirstPage.innerRect.stackFromChild, mainWindow.pageStack)

        let layer1Page = mainWindow.pageStack.layers.currentItem
        compare(layer1Page.outerStack, mainWindow.pageStack.layers)
        compare(layer1Page.innerRect.stackFromChild, mainWindow.pageStack.layers)
    }

    function test_changeParent(): void {
        compare(mainWindow.pageStack.depth, 0)
        mainWindow.pageStack.push(samplePage)
        compare(mainWindow.pageStack.depth, 1)

        let pageRowFirstPage = mainWindow.pageStack.items[0]

        compare(pageRowFirstPage.outerStack, mainWindow.pageStack)
        compare(pageRowFirstPage.innerRect.stackFromChild, mainWindow.pageStack)

        mainWindow.pageStack.push(pageWithInnerStack)
        compare(mainWindow.pageStack.depth, 2)

        let pageRowSecondPage = mainWindow.pageStack.items[1]

        compare(pageRowSecondPage.stack, mainWindow.pageStack)

        spyStackChanged.target = pageRowFirstPage.innerRect.Kirigami.PageStack
        // First we make sure the internal stack has an attached property created
        verify(pageRowSecondPage.subStack.Kirigami.PageStack.pageStack)
        pageRowSecondPage.subStack.push(pageRowFirstPage.innerRect)
        tryCompare(spyStackChanged, "count", 1)
        compare(pageRowFirstPage.innerRect.parent, pageRowSecondPage.subStack)
        compare(pageRowFirstPage.innerRect.stackFromChild, pageRowSecondPage.subStack);
    }

    function test_changeParent_attachedNotExisting(): void {
        // Here will reparent to a stackview in a page which
        // doesn't have a stackattached created yet
        compare(mainWindow.pageStack.depth, 0)
        mainWindow.pageStack.push(samplePage)
        compare(mainWindow.pageStack.depth, 1)

        let pageRowFirstPage = mainWindow.pageStack.items[0]

        compare(pageRowFirstPage.outerStack, mainWindow.pageStack)
        compare(pageRowFirstPage.innerRect.stackFromChild, mainWindow.pageStack)

        mainWindow.pageStack.push(pageWithInnerStack)
        compare(mainWindow.pageStack.depth, 2)

        let pageRowSecondPage = mainWindow.pageStack.items[1]

        compare(pageRowSecondPage.stack, mainWindow.pageStack)

        spyStackChanged.target = pageRowFirstPage.innerRect.Kirigami.PageStack
        pageRowSecondPage.subStack.push(pageRowFirstPage.innerRect)
        tryCompare(spyStackChanged, "count", 1)

        compare(pageRowFirstPage.innerRect.parent, pageRowSecondPage.subStack)
        compare(pageRowFirstPage.innerRect.stackFromChild, pageRowSecondPage.subStack);
    }

    function test_attachedPushPopOnPageRow(): void {
        compare(mainWindow.pageStack.depth, 0)
        mainWindow.pageStack.push(samplePage)
        compare(mainWindow.pageStack.depth, 1)

        let pageRowFirstPage = mainWindow.pageStack.items[0]
        pageRowFirstPage.Kirigami.PageStack.push(samplePage);
        compare(mainWindow.pageStack.depth, 2)

        let pageRowSecondPage = mainWindow.pageStack.items[1]
        pageRowSecondPage.innerRect.Kirigami.PageStack.push(samplePage)
        compare(mainWindow.pageStack.depth, 3)

        pageRowFirstPage.Kirigami.PageStack.pop(pageRowFirstPage)
        compare(mainWindow.pageStack.depth, 1)
    }

    function test_attachedPushPopOnStackView(): void {
        compare(mainWindow.pageStack.depth, 0)
        mainWindow.pageStack.push(pageWithInnerStack)
        compare(mainWindow.pageStack.depth, 1)

        let pageRowFirstPage = mainWindow.pageStack.items[0]
        pageRowFirstPage.subStack.push(samplePage)
        compare(pageRowFirstPage.subStack.depth, 1)

        let subStackFirstPage = pageRowFirstPage.subStack.currentItem

        subStackFirstPage.Kirigami.PageStack.push(samplePage)
        compare(pageRowFirstPage.subStack.depth, 2)
        subStackFirstPage.Kirigami.PageStack.push(samplePage)
        compare(pageRowFirstPage.subStack.depth, 3)

        subStackFirstPage.Kirigami.PageStack.pop(subStackFirstPage)
        compare(pageRowFirstPage.subStack.depth, 1)
    }

    function test_attachedClearOnPageRow(): void {
        compare(mainWindow.pageStack.depth, 0)
        mainWindow.pageStack.push(samplePage)
        compare(mainWindow.pageStack.depth, 1)

        let pageRowFirstPage = mainWindow.pageStack.items[0]
        pageRowFirstPage.Kirigami.PageStack.push(samplePage);
        compare(mainWindow.pageStack.depth, 2)

        let pageRowSecondPage = mainWindow.pageStack.items[1]
        pageRowSecondPage.innerRect.Kirigami.PageStack.push(samplePage)
        compare(mainWindow.pageStack.depth, 3)

        pageRowFirstPage.Kirigami.PageStack.clear()
        compare(mainWindow.pageStack.depth, 0)
    }

    function test_attachedClearOnStackView(): void {
        compare(mainWindow.pageStack.depth, 0)
        mainWindow.pageStack.push(pageWithInnerStack)
        compare(mainWindow.pageStack.depth, 1)

        let pageRowFirstPage = mainWindow.pageStack.items[0]
        pageRowFirstPage.subStack.push(samplePage)
        compare(pageRowFirstPage.subStack.depth, 1)

        let subStackFirstPage = pageRowFirstPage.subStack.currentItem

        subStackFirstPage.Kirigami.PageStack.push(samplePage)
        compare(pageRowFirstPage.subStack.depth, 2)
        subStackFirstPage.Kirigami.PageStack.push(samplePage)
        compare(pageRowFirstPage.subStack.depth, 3)

        subStackFirstPage.Kirigami.PageStack.clear()
        compare(pageRowFirstPage.subStack.depth, 0)
    }
}
