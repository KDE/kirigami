/*
 *  SPDX-FileCopyrightText: 2024 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import QtTest

TestCase {
    name: "Cards"
    visible: true
    when: windowShown

    width: 500
    height: 500

    Component {
        id: cardComponent
        Kirigami.Card {}
    }

    Component {
        id: cardWithActionsComponent
        Kirigami.Card {
            actions: [
                QQC2.Action {
                    text: "QQC2"
                },
                Kirigami.Action {
                    text: "Kirigami"
                }
            ]
        }
    }

    function test_init() {
        const card = createTemporaryObject(cardComponent, this);
        verify(card);
    }

    function test_cardWithActions() {
        const card = createTemporaryObject(cardWithActionsComponent, this);
        verify(card);
    }
}
