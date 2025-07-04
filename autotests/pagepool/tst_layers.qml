/*
 *  SPDX-FileCopyrightText: 2020 Mason McParlane <mtmcp@outlook.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Window
import org.kde.kirigami as Kirigami
import QtTest

TestCase {
    id: testCase
    width: 400
    height: 400
    name: "PagePoolWithLayers"
    when: windowShown

    function initTestCase() {
        mainWindow.show()
    }

    function cleanupTestCase() {
        mainWindow.close()
    }

    Kirigami.ApplicationWindow {
        id: mainWindow
        width: 480
        height: 360
    }

    Kirigami.PagePool {
        id: pool
    }

    SignalSpy {
        id: stackSpy
        target: mainWindow.pageStack
        signalName: "onCurrentItemChanged"
    }

    SignalSpy {
        id: layerSpy
        target: mainWindow.pageStack.layers
        signalName: "onCurrentItemChanged"
    }


    function init() {
        pool.clear()
        mainWindow.pageStack.layers.clear()
        compare(mainWindow.pageStack.layers.depth, 1)
        mainWindow.pageStack.clear()

        for (var spy of [stackSpy, layerSpy, checkSpy_A, checkSpy_B, checkSpy_C, checkSpy_D, checkSpy_E]) {
            spy.clear()
        }

        // Give mainWindow a bit of room to breathe so it can process item
        // deletion and other delayed signals.
        wait(50)
    }

    ActionGroup {
        id: group
        exclusive: false

        Kirigami.PagePoolAction {
            id: stackPageA
            objectName: "stackPageA"
            pagePool: pool
            pageStack: mainWindow.pageStack
            page: "TestPage.qml?page=A"
            initialProperties: { return {title: "A", objectName: "Page A" } }
        }

        Kirigami.PagePoolAction {
            id: stackPageB
            objectName: "stackPageB"
            pagePool: pool
            pageStack: mainWindow.pageStack
            page: "TestPage.qml?page=B"
            initialProperties: { return {title: "B", objectName: "Page B" } }
        }

        Kirigami.PagePoolAction {
            id: layerPageC
            objectName: "layerPageC"
            pagePool: pool
            pageStack: mainWindow.pageStack
            useLayers: true
            page: "TestPage.qml?page=C"
            initialProperties: { return {title: "C", objectName: "Page C" } }
        }

        Kirigami.PagePoolAction {
            id: layerPageD
            objectName: "layerPageD"
            pagePool: pool
            pageStack: mainWindow.pageStack
            useLayers: true
            page: "TestPage.qml?page=D"
            initialProperties: { return {title: "D", objectName: "Page D" } }
        }

        Kirigami.PagePoolAction {
            id: stackPageE
            objectName: "stackPageE"
            pagePool: pool
            pageStack: mainWindow.pageStack
            page: "TestPage.qml?page=E"
            initialProperties: { return {title: "E", objectName: "Page E" } }
        }
    }

    function tapBack () {
        mouseClick(mainWindow, 10, 10)
    }

    function test_pushLayerBackButtonPushAgain() {
        var stack = mainWindow.pageStack
        var layers = stack.layers

        function pushA() {
            stackPageA.trigger()
            compare(stack.currentItem, pool.lastLoadedItem)
        }

        function pushC () {
            layerPageC.trigger()
            compare(layers.currentItem, pool.lastLoadedItem)
        }

        function pushD () {
            layerPageD.trigger()
            compare(layers.currentItem, pool.lastLoadedItem)
        }

        compare(stackSpy.count, 0)
        pushA()
        compare(stackSpy.count, 1)
        compare(layerSpy.count, 0)
        pushC()
        compare(layerSpy.count, 1)
        pushD()
        compare(layerSpy.count, 2)
        compare(stackSpy.count, 1)
        // The back button is being slided in with the push animation, so wait for it to be done
        tryCompare(mainWindow.pageStack.layers, "busy", false)
        tapBack()
        compare(layerSpy.count, 3)
        pushD()
        compare(layerSpy.count, 4)
    }

    SignalSpy {
        id: checkSpy_A
        target: stackPageA
        signalName: "onCheckedChanged"
    }

    SignalSpy {
        id: checkSpy_B
        target: stackPageB
        signalName: "onCheckedChanged"
    }

    SignalSpy {
        id: checkSpy_C
        target: layerPageC
        signalName: "onCheckedChanged"
    }

    SignalSpy {
        id: checkSpy_D
        target: layerPageD
        signalName: "onCheckedChanged"
    }

    SignalSpy {
        id: checkSpy_E
        target: stackPageE
        signalName: "onCheckedChanged"
    }
    
    function dump_layers(msg = "") {
        for (var i = 0; i < mainWindow.pageStack.layers.depth; ++i) {
            console.debug(`${msg} ${i}: ${mainWindow.pageStack.layers.get(i)}`)
        }
    }

    function test_checked() {
        var stack = mainWindow.pageStack
        var layers = stack.layers

        function testCheck(expected = {}) {
            let defaults = {
                a: false, b: false, c: false, d: false, e: false
            }
            let actual = Object.assign({}, defaults, expected)
            let pages = {a: stackPageA, b: stackPageB, c: layerPageC, d: layerPageD, e: stackPageE}
            
            for (const prop in actual) {
                compare(pages[prop].checked, actual[prop],
                    `${pages[prop]} should ${actual[prop] ? 'be checked' : 'not be checked'}`)
            }
        }

        testCheck()
        
        compare(stackSpy.count, 0)
        compare(layerSpy.count, 0)
        compare(checkSpy_A.count, 0)
        compare(checkSpy_B.count, 0)
        compare(checkSpy_C.count, 0)
        compare(checkSpy_D.count, 0)
        compare(checkSpy_E.count, 0)

        stackPageA.trigger()
        compare(checkSpy_A.count, 1)
        testCheck({a:true})
        compare(stack.currentItem, stackPageA.pageItem())

        stackPageB.trigger()
        compare(checkSpy_A.count, 2)
        compare(checkSpy_B.count, 3)
        testCheck({b:true})
        compare(stack.currentItem, stackPageB.pageItem())

        layerPageC.trigger()
        testCheck({b:true, c:true})
        compare(checkSpy_C.count, 1)
        compare(stack.currentItem, stackPageB.pageItem())
        compare(layers.currentItem, layerPageC.pageItem())
        compare(layerPageC.layerContainsPage(), true)

        layerPageD.trigger()
        compare(stack.currentItem, stackPageB.pageItem())
        compare(layers.currentItem, layerPageD.pageItem())
        testCheck({b:true, c:true, d:true})

        stackPageE.basePage = stack.currentItem
        stackPageE.trigger()
        testCheck({b:true, e:true})
        compare(stack.currentItem, stackPageE.pageItem())
        verify(!(layers.currentItem instanceof Page),
                    `Current item ${layers.currentItem} is a page but all pages should be popped`)

        stackPageA.trigger()
        testCheck({a:true})
        compare(stack.currentItem, stackPageA.pageItem())
        verify(!(layers.currentItem instanceof Page),
                    `Current item ${layers.currentItem} is a page but all pages should be popped`)

        compare(checkSpy_A.count, 5)
        compare(checkSpy_B.count, 4)
        compare(checkSpy_C.count, 2)
        compare(checkSpy_D.count, 2)
        compare(checkSpy_E.count, 2)
    }

    function test_push_A_C_D_A_popsLayers() {
        var stack = mainWindow.pageStack
        var layers = stack.layers

        stackPageA.trigger()
        compare(stack.currentItem, stackPageA.pageItem())

        layerPageC.trigger()
        compare(layers.currentItem, layerPageC.pageItem())

        layerPageD.trigger()
        compare(layers.currentItem, layerPageD.pageItem())

        stackPageA.trigger()
        compare(stack.currentItem, stackPageA.pageItem())
        verify(!(layers.currentItem instanceof Page),
                    `Current item ${layers.currentItem} is a page but all pages should be popped`)
    }

    function test_push_A_C_D_back_back_C_back_C() {
        var stack = mainWindow.pageStack
        var layers = stack.layers

        stackPageA.trigger()
        layerPageC.trigger()
        layerPageD.trigger()
        tapBack()
        tapBack()
        layerPageC.trigger()
        tapBack()
        layerPageC.trigger()
        compare(layers.currentItem, layerPageC.pageItem())
    }

    function test_exclusive_group() {
        var stack = mainWindow.pageStack
        var layers = stack.layers

        group.exclusive = true
        stackPageA.trigger()
        compare(stackPageA.checked, true)
        compare(layerPageC.checked, false)
        layerPageC.trigger()
        compare(stackPageA.checked, false)
        compare(layerPageC.checked, true)
        // The back button is being slided in with the push animation, so wait for it to be done
        tryCompare(mainWindow.pageStack.layers, "busy", false)
        tapBack()
        compare(stackPageA.checked, true)
        compare(layerPageC.checked, false)
    }
}
