// SPDX-FileCopyrightText: ⓒ 2025 Volker Krause <vkrause@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "safearea.h"

using namespace Kirigami;

SafeAreaAttached::SafeAreaAttached(QObject *parent)
    : QObject(parent)
{
}

QMarginsF SafeAreaAttached::margins() const
{
    return {};
}

SafeAreaAttached *SafeAreaAttached::qmlAttachedProperties(QObject *object)
{
    return new SafeAreaAttached(object);
}

#include "moc_safearea.cpp"
