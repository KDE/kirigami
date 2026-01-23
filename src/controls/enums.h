/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef ENUMS_H
#define ENUMS_H

#include <QObject>
#include <QQmlEngine>

namespace ApplicationHeaderStyle
{
Q_NAMESPACE
QML_ELEMENT

enum Status {
    Auto = 0,
    Breadcrumb,
    Titles,
    ToolBar, ///\since 5.48
    None, ///\since 5.48
};
Q_ENUM_NS(Status)

enum NavigationButton {
    NoNavigationButtons = 0,
    ShowBackButton = 0x1,
    ShowForwardButton = 0x2,
};
Q_ENUM_NS(NavigationButton)
Q_DECLARE_FLAGS(NavigationButtons, NavigationButton)
}

namespace MessageType
{
Q_NAMESPACE
QML_ELEMENT

enum Type {
    Information = 0,
    Positive,
    Warning,
    Error,
};
Q_ENUM_NS(Type)
};

#endif // ENUMS_H
