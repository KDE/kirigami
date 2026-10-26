/*
 *  SPDX-FileCopyrightText: 2023 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtTest
import org.kde.kirigami as Kirigami

TestCase {
    id: testCase
    name: "NameUtilsTest"

    function test_initials() {
        compare(Kirigami.NameUtils.initialsFromString("John Doe"), "JD");
        compare(Kirigami.NameUtils.initialsFromString("Юрий Гагарин"), "ЮГ");
        compare(Kirigami.NameUtils.initialsFromString("Ἑκάτη Παππάς"), "ΕΠ");
        compare(Kirigami.NameUtils.initialsFromString("가영"), "ᄀ");
        compare(Kirigami.NameUtils.initialsFromString("陈雅"), "陈");
        compare(Kirigami.NameUtils.initialsFromString("आरव विहान"), "आव");
        compare(Kirigami.NameUtils.initialsFromString("เจริญ นครินทร์"), "เน");
    }

    function test_colors(data) {
        compare(Kirigami.NameUtils.colorsFromString("John Doe"), "#b6e521");
        compare(Kirigami.NameUtils.colorsFromString("Юрий Гагарин"), "#00d3b8");
        compare(Kirigami.NameUtils.colorsFromString("Ἑκάτη Παππάς"), "#b875dc");
        compare(Kirigami.NameUtils.colorsFromString("가영"), "#e93d58");
        compare(Kirigami.NameUtils.colorsFromString("陈雅"), "#3daee9");
        compare(Kirigami.NameUtils.colorsFromString("आरव विहान"), "#e93d58");
        compare(Kirigami.NameUtils.colorsFromString("เจริญ นครินทร์"), "#e8cb2d");
    }

    function test_unsuitable() {
        Kirigami.NameUtils.isStringUnsuitableForInitials("🤔")
    }
}

