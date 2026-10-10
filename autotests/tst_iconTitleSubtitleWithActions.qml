/*
 *  SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
 *  SPDX-FileCopyrightText: 2026 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kirigami.delegates as KD
import QtTest

TestCase {
    id: testCase

    width: 400
    height: 400
    name: "TitleSubtitleWithActionsTest"
    visible: false
    Component {
        id: testComponent

        KD.IconTitleSubtitleWithActions {
            icon.name: "edit-bomb"
            title: "AAAA"
            subtitle: "BBBB"
            elide: Text.ElideRight
            selected: false
            actions: [
                Kirigami.Action {
                    icon.name: "edit-entry-symbolic"
                    text: "Modify item…"
                    onTriggered: console.warn("I dont actually do anything")
                    tooltip: text
                },
                Kirigami.Action {
                    icon.name: "edit-delete-remove-symbolic"
                    text: "Remove item…"
                    onTriggered: console.warn("I also dont actually do anything")
                    tooltip: "Custom tooltip"
                    displayHint: Kirigami.DisplayHint.IconOnly
                }
            ]
        }
    }

    function test_verifyValues() {
        const tc = createTemporaryObject(testComponent, this);
        verify(tc instanceof Kirigami.IconTitleSubtitleWithActions);
        verify(tc.icon.name === "edit-bomb");
        verify(tc.title === "AAAA");
        verify(tc.subtitle === "BBBB");
        verify(tc.elide === Text.ElideRight);
        verify(tc.selected === false);
        verify(tc.displayHint === QQC2.Button.TextBesideIcon);

        verify(tc.actions[0] instanceof Kirigami.Action);
        verify(tc.actions[0].icon.name === "edit-entry-symbolic");
        verify(tc.actions[0].text === "Modify item…");
        verify(tc.actions[0].tooltip === tc.actions[0].text);
        verify(tc.actions[0].displayHint === Kirigami.DisplayHint.NoPreference);

        verify(tc.actions[1] instanceof Kirigami.Action);
        verify(tc.actions[1].icon.name === "edit-delete-remove-symbolic");
        verify(tc.actions[1].text === "Remove item…");
        verify(tc.actions[1].tooltip === "Custom tooltip");
        verify(tc.actions[1].displayHint === Kirigami.DisplayHint.IconOnly);
    }
}
