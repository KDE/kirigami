/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

/*!
  \brief PassiveNotificationManager is meant to display small, passive and inline notifications in the app.

  It is used to show messages of limited importance that make sense only when
  the user is using the application and wouldn't be suited as a global
  system-wide notification.
  \internal
*/
Item {
    id: root

    readonly property int maximumNotificationWidth: {
        if (Kirigami.Settings.isMobile) {
            return applicationWindow().width - Kirigami.Units.largeSpacing * 4
        } else {
            return Math.min(Kirigami.Units.gridUnit * 25, applicationWindow().width / 1.5)
        }
    }

    readonly property int maximumNotificationCount: 4

    function showNotification(message, timeout, actionText, callBack) {
        if (!message) {
            return;
        }

        let interval = 7000;

        if (timeout === "short") {
            interval = 4000;
        } else if (timeout === "long") {
            interval = 12000;
        } else if (timeout > 0) {
            interval = timeout;
        }

        // this wrapper is necessary because of Qt casting a function into an object
        const callBackWrapperObj = callBackWrapper.createObject(listView, { callBack })

        // set empty string & function for qml not to complain
        notificationsModel.append({
            text: message,
            actionButtonText: actionText || "",
            closeInterval: interval,
            callBackWrapper: callBackWrapperObj
        })
        // remove the oldest notification if new notification count would exceed 3
        if (notificationsModel.count === maximumNotificationCount) {
            if (listView.itemAtIndex(0).hovered === true) {
                hideNotification(1)
            } else {
                hideNotification()
            }
        }
    }

    /*!
     * \brief Remove a notification at specific index. By default, index is set to 0.
     */
    function hideNotification(index = 0) {
        if (index >= 0 && notificationsModel.count > index) {
            const callBackWrapperObj = notificationsModel.get(index).callBackWrapper
            if (callBackWrapperObj) {
                callBackWrapperObj.destroy()
            }
            notificationsModel.remove(index)
        }
    }

    // we have to set height to show more than one notification
    height: Math.min(applicationWindow().height, Kirigami.Units.gridUnit * 10)

    implicitHeight: listView.implicitHeight
    implicitWidth: listView.implicitWidth

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    ListModel {
        id: notificationsModel
    }

    ListView {
        id: listView

        anchors.fill: parent
        anchors.bottomMargin: Kirigami.Units.largeSpacing

        implicitWidth: root.maximumNotificationWidth
        spacing: Kirigami.Units.smallSpacing
        model: notificationsModel
        verticalLayoutDirection: ListView.BottomToTop
        keyNavigationEnabled: false
        reuseItems: false  // do not resue items, otherwise delegates do not hide themselves properly
        focus: false
        interactive: false

        add: Transition {
            id: addAnimation
            ParallelAnimation {
                alwaysRunToEnd: true
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "y"
                    from: addAnimation.ViewTransition.destination.y - Kirigami.Units.gridUnit * 3
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
        displaced: Transition {
            ParallelAnimation {
                alwaysRunToEnd: true
                NumberAnimation {
                    property: "y"
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    property: "opacity"
                    duration: Kirigami.Units.longDuration
                    to: 1
                }
            }
        }
        remove: Transition {
            ParallelAnimation {
                alwaysRunToEnd: true
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    property: "y"
                    to: Kirigami.Units.gridUnit * 3
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InCubic
                }
                PropertyAction {
                    property: "transformOrigin"
                    value: Item.Bottom
                }
                PropertyAnimation {
                    property: "scale"
                    from: 1
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InCubic
                }
            }
        }
        delegate: QQC2.Control {
            id: delegate

            hoverEnabled: true
            // We force the delegate to be not visible when
            // created, as this could cause some flickering
            // otherwise; instead, we rely on `add` and
            // `displaced` animations to change the opacity.
            opacity: Kirigami.Units.longDuration > 0 ? 0 : 1

            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
            width: Math.min(implicitWidth, maximumNotificationWidth)
            implicitHeight: {
                // HACK: contentItem.implicitHeight needs to be updated manually for some reason
                void contentItem.implicitHeight;
                return Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                implicitContentHeight + topPadding + bottomPadding);
            }
            z: {
                if (delegate.hovered) {
                    return 2;
                } else if (delegate.index === 0) {
                    return 1;
                } else {
                    return 0;
                }
            }

            leftPadding: Kirigami.Units.largeSpacing
            rightPadding: Kirigami.Units.largeSpacing
            topPadding: Kirigami.Units.largeSpacing
            bottomPadding: Kirigami.Units.largeSpacing

            contentItem: RowLayout {
                id: mainLayout

                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: root.Kirigami.Theme.colorSet

                spacing: Kirigami.Units.mediumSpacing

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: eventPoint => hideNotification(index)
                }
                Timer {
                    id: timer
                    interval: model.closeInterval
                    running: !delegate.hovered
                    onTriggered: hideNotification(index)
                }

                QQC2.Label {
                    id: label
                    text: model.text
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }

                QQC2.Button {
                    id: actionButton
                    text: model.actionButtonText
                    visible: text.length > 0
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: {
                        const callBack = model.callBackWrapper.callBack
                        hideNotification(index)
                        if (callBack && (typeof callBack === "function")) {
                            callBack();
                        }
                    }
                }
            }
            background: Kirigami.ShadowedRectangle {
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: root.Kirigami.Theme.colorSet
                shadow {
                    size: Kirigami.Units.gridUnit/2
                    color: Qt.rgba(0, 0, 0, 0.4)
                    yOffset: 2
                }
                radius: Kirigami.Units.cornerRadius
                color: Kirigami.Theme.backgroundColor
                opacity: 0.9
            }
        }
    }
    Component {
        id: callBackWrapper
        QtObject {
            property var callBack
        }
    }
}

