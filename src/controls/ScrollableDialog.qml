/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.18 as Kirigami

Kirigami.Dialog {
    id: root
    default property Item mainItem
    
    padding: 0
    
    contentItem: Controls.ScrollView {
        id: scrollView
        implicitWidth: root.mainItem.implicitWidth
        contentHeight: root.mainItem.implicitHeight
        contentItem: root.mainItem
        
        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
        Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
    }
}
