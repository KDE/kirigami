// SPDX-FileCopyrightText: 2026 Nicolas Fella <nicolas.fella@gmx.de>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import org.kde.kirigami as Kirigami
import QtTest
import KirigamiTestUtils

TestCase {
    name: "AboutItem"

    Kirigami.AboutItem {
        aboutData: {
            "displayName" : "KirigamiApp",
            "productName" : "kirigami/app",
            "componentName" : "kirigamiapp",
            "shortDescription" : "A Kirigami example",
            "homepage" : "",
            "bugAddress" : "submit@bugs.kde.org",
            "version" : "5.14.80",
            "otherText" : "",
            "authors" : [
                {
                    "name" : "...",
                    "task" : "",
                    "emailAddress" : "somebody@kde.org",
                    "webAddress" : "",
                    "ocsUsername" : ""
                }
            ],
            "credits" : [],
            "translators" : [],
            "licenses" : [
                {
                    "name" : "GPL v2",
                    "text" : "long, boring, license text",
                    "spdx" : "GPL-2.0"
                }
            ],
            "copyrightStatement" : "© 2010-2018 Plasma Development Team",
            "desktopFileName" : "org.kde.kirigamiapp"
        }
    }
}
