/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import QtTest

TestCase {
    name: "AvatarTest"
    visible: true
    when: windowShown

    width: 500
    height: 500

    Kirigami.Avatar {
        id: avatar
        anchors.centerIn: parent
        name: "John Doe"
    }

    Component {
        id: avatarButtonComponent
        Kirigami.AvatarButton {
            name: "Jane Doe"
        }
    }

    function test_avatar() {
        verify(avatar);
    }

    function test_avatarButton() {
        const avatarButton = createTemporaryObject(avatarButtonComponent, this);
        verify(avatarButton);

        compare(avatarButton.leftInset, 0);
        mousePress(avatarButton);
        compare(avatarButton.leftInset, -1);
        mouseRelease(avatarButton);
        compare(avatarButton.leftInset, 0);
    }
}
