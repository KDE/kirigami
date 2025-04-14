/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: app

    property string iconSource: "home"
    property bool iconEnabled: true
    property bool iconAnimated: false
    property real iconSize: Kirigami.Units.iconSizes.large

    Component {
        id: delegateComponent
        Kirigami.Card {
            contentItem: Label { text: ourlist.prefix + index }
        }
    }

    pageStack.initialPage: Kirigami.Page {
        actions: [
            Kirigami.Action {
                text: "Switch Icon"
                onTriggered: {
                    if (app.iconSource === "home") {
                        app.iconSource = "window-new";
                    } else {
                        app.iconSource = "home";
                    }
                }
            },
            Kirigami.Action {
                text: "Enabled"
                checkable: true
                checked: app.iconEnabled
                onTriggered: app.iconEnabled = !app.iconEnabled
            },
            Kirigami.Action {
                text: "Animated"
                checkable: true
                checked: app.iconAnimated
                onTriggered: app.iconAnimated = !app.iconAnimated
            },
            Kirigami.Action {
                displayComponent: RowLayout {
                    Label {
                        text: "Size:"
                    }
                    SpinBox {
                        from: 0
                        to: Kirigami.Units.iconSizes.enormous
                        value: Kirigami.Units.iconSizes.large
                        onValueModified: {
                            app.iconSize = value
                        }
                    }
                }
            }
        ]

        Column {
            Row {
                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: app.iconSource
                    enabled: app.iconEnabled
                    animated: app.iconAnimated
                }

                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: app.iconSource
                    enabled: app.iconEnabled
                    animated: app.iconAnimated

                    active: handler1.hovered
                    HoverHandler { id: handler1 }
                }

                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: app.iconSource
                    enabled: app.iconEnabled
                    animated: app.iconAnimated

                    selected: true
                }

                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: app.iconSource
                    enabled: app.iconEnabled
                    animated: app.iconAnimated

                    color: "red"
                }
            }

            Row {
                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: app.iconSource
                    enabled: app.iconEnabled
                    animated: app.iconAnimated
                    isMask: true
                }

                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: app.iconSource
                    enabled: app.iconEnabled
                    animated: app.iconAnimated
                    isMask: true

                    active: handler2.hovered
                    HoverHandler { id: handler2 }
                }

                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: app.iconSource
                    enabled: app.iconEnabled
                    animated: app.iconAnimated
                    isMask: true

                    selected: true
                }

                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: app.iconSource
                    enabled: app.iconEnabled
                    animated: app.iconAnimated
                    isMask: true

                    color: "red"
                }
            }

            Row {
                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: "audio-volume-medium-symbolic"
                    enabled: app.iconEnabled
                    animated: app.iconAnimated
                }

                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: "audio-volume-medium-symbolic"
                    enabled: app.iconEnabled
                    animated: app.iconAnimated

                    active: handler3.hovered
                    HoverHandler { id: handler3 }
                }

                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: "audio-volume-medium-symbolic"
                    enabled: app.iconEnabled
                    animated: app.iconAnimated

                    selected: true
                }

                Kirigami.Icon {
                    width: app.iconSize
                    height: width
                    source: "audio-volume-medium-symbolic"
                    enabled: app.iconEnabled
                    animated: app.iconAnimated

                    color: "red"
                }
            }
        }

    }
}
