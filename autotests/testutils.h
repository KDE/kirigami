// SPDX-FileCopyrightText: 2026 Matej Starc <matej.starc@protonmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QGuiApplication>
#include <QObject>
#include <qqmlregistration.h>

class TestUtils : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit TestUtils(QObject *parent = nullptr)
        : QObject(parent)
    {
    }

    Q_INVOKABLE void setLayoutDirection(Qt::LayoutDirection direction)
    {
        QGuiApplication::setLayoutDirection(direction);
    }
};
