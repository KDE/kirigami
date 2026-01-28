/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQml
import QtQuick.Templates as T
import org.kde.kirigami.controls as KC

/*!
  \qmltype PagePoolAction
  \inqmlmodule org.kde.kirigami

  \brief An action used to load Pages coming from a common PagePool
  in a PageRow or QtQuickControls2 StackView.

  \sa PagePool
 */
KC.Action {
    id: root

//BEGIN properties
    /*!
      \brief This property holds the url or filename of the page that this action will load.
     */
    property string page

    /*!
      \brief This property holds the PagePool object used by this PagePoolAction.

      PagePool will make sure only one instance of the page identified by the page url will be created and reused.

      PagePool's lastLoaderUrl property will be used to control the mutual exclusivity of the checked
      state of the PagePoolAction instances sharing the same PagePool.
     */
    property KC.PagePool pagePool

    /*!
      The pageStack property accepts either a Kirigami.PageRow or a QtQuickControls2 StackView;
      the component that will instantiate the pages, which has to work with a stack logic.

      Kirigami.PageRow is recommended, but will work with QtQuicControls2 StackView as well.

      default: bound to ApplicationWindow's global pageStack, which is a PageRow by default
     */
    property Item pageStack: typeof applicationWindow !== 'undefined' ? applicationWindow().pageStack : null

    /*!
      \qmlproperty Page basePage
      \brief This property sets the page in the pageStack after which
      new pages will be pushed.

      All pages present after the given basePage will be removed from the pageStack
     */
    property T.Page basePage

    /*!
      This property holds a function that generate the property values for the created page
      when it is pushed onto the Kirigami.PagePool.

      Example usage:
      \qml
      Kirigami.PagePoolAction {
          text: i18n("Security")
          icon.name: "security-low"
          page: Qt.resolvedUrl("Security.qml")
          initialProperties: {
              return {
                  room: root.room
              }
          }
      }
      \endqml
     */
    property var initialProperties

    /*!
      \brief This property sets whether PagePoolAction will use the layers property
      implemented by the pageStack.

      This is intended for use with PageRow layers to allow PagePoolActions to
      push context-specific pages onto the layers stack.

      default: \c false

      \since 5.70
     */
    property bool useLayers: false
//END properties

    /*!
      \qmlmethod Item PagePoolAction::pageItem()

      Returns the page item held in the PagePool or null if it has not been loaded yet.
     */
    function pageItem(): Item {
        return pagePool.pageForUrl(page)
    }

    /*!
      \qmlmethod bool PagePoolAction::layerContainsPage()
      Returns \c true if the page has been loaded and placed on \c pageStack.layers
      and useLayers is true, otherwise returns \c null.
     */
    function layerContainsPage(): bool {
        if (!useLayers || !pageStack.hasOwnProperty("layers")) {
            return false;
        }

        const pageItem = this.pageItem();
        const item = pageStack.layers.find(item => item === pageItem);
        return item !== null;
    }

    /*!
      \qmlmethod bool PagePoolAction::stackContainsPage()

      Returns \c true if the page has been loaded and placed on the pageStack,
      otherwise returns \c null.
     */
    function stackContainsPage(): bool {
        if (useLayers) {
            return false;
        }
        return pageStack.columnView.containsItem(pagePool.pageForUrl(page));
    }

    checkable: true

    onTriggered: {
        if (page.length === 0 || !pagePool || !pageStack) {
            return;
        }

        // User intends to "go back" to this layer.
        const pageItem = this.pageItem();
        if (layerContainsPage() && pageItem !== pageStack.layers.currentItem) {
            pageStack.layers.replace(pageItem, pageItem); // force pop above
            return;
        }

        // User intends to "go back" to this page.
        if (stackContainsPage()) {
            if (pageStack.hasOwnProperty("layers")) {
                pageStack.layers.clear();
            }
        }

        const stack = useLayers ? pageStack.layers : pageStack

        if (pageItem != null && stack.currentItem == pageItem) {
            return;
        }

        if (initialProperties && typeof(initialProperties) !== "object") {
            console.warn("initialProperties must be of type object");
            return;
        }

        if (!stack.hasOwnProperty("pop") || typeof stack.pop !== "function" || !stack.hasOwnProperty("push") || typeof stack.push !== "function") {
            return;
        }

        if (pagePool.isLocalUrl(page)) {
            if (basePage) {
                stack.pop(basePage);

            } else if (!useLayers) {
                stack.clear();
            }

            stack.push(initialProperties
                ? pagePool.loadPageWithProperties(page, initialProperties)
                : pagePool.loadPage(page));
        } else {
            const callback = item => {
                if (basePage) {
                    stack.pop(basePage);

                } else if (!useLayers) {
                    stack.clear();
                }

                stack.push(item);
            };

            if (initialProperties) {
                pagePool.loadPage(page, initialProperties, callback);

            } else {
                pagePool.loadPage(page, callback);
            }
        }
    }

    // Exposing this as a property is required as Action does not have a default property
    property QtObject _private: QtObject {
        id: _private

        function setChecked(checked) {
            root.checked = checked;
        }

        function clearLayers() {
            root.pageStack.layers.clear();
        }

        property list<Connections> connections: [
            Connections {
                target: root.pageStack

                function onCurrentItemChanged() {
                    if (root.useLayers) {
                        if (root.layerContainsPage()) {
                            _private.clearLayers();
                        }
                        if (root.checkable) {
                            _private.setChecked(false);
                        }

                    } else {
                        if (root.checkable) {
                            _private.setChecked(root.stackContainsPage());
                        }
                    }
                }
            },
            Connections {
                enabled: root.pageStack.hasOwnProperty("layers")
                target: root.pageStack.layers

                function onCurrentItemChanged() {
                    if (root.useLayers && root.checkable) {
                        _private.setChecked(root.layerContainsPage());

                    } else {
                        if (root.pageStack.layers.depth === 1 && root.stackContainsPage()) {
                            _private.setChecked(true);
                        }
                    }
                }
            }
        ]
    }
}
