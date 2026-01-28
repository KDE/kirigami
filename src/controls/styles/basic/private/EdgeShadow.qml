/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.platform as Platform

Item {
    id: shadow
    /*!
      \brief This property holds the edge of the shadow that will determine the direction of the gradient.
      The acceptable values are:
      - Qt.TopEdge: the top edge of the content item.
      - Qt.LeftEdge: the left edge of the content item
      - Qt.RightEdge: the right edge of the content item.
      - Qt.BottomEdge: the bottom edge of the content item.

      \sa Qt::Edges
     */
    property int edge: Qt.LeftEdge

    property int radius: Platform.Units.cornerRadius
    implicitWidth: radius
    implicitHeight: radius

    Rectangle {
        x: shadow.width / 2 - width / 2
        y: shadow.height / 2 - height / 2
        width: (shadow.edge === Qt.LeftEdge || shadow.edge === Qt.RightEdge) ? shadow.height : shadow.width
        height: (shadow.edge === Qt.LeftEdge || shadow.edge === Qt.RightEdge) ? shadow.width : shadow.height
        rotation: {
            switch (shadow.edge) {
                case Qt.TopEdge: return 0;
                case Qt.LeftEdge: return 270;
                case Qt.RightEdge: return 90;
                case Qt.BottomEdge: return 180;
            }
        }

       gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.rgba(0, 0, 0, 0.25)
            }
            GradientStop {
                position: 0.20
                color: Qt.rgba(0, 0, 0, 0.1)
            }
            GradientStop {
                position: 0.35
                color: Qt.rgba(0, 0, 0, 0.02)
            }
            GradientStop {
                position: 1.0
                color:  "transparent"
            }
        }
    }
}

