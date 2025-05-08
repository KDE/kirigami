// SPDX-FileCopyrightText: ⓒ 2025 Volker Krause <vkrause@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#ifndef KIRIGAMI_SAFEAREA_H
#define KIRIGAMI_SAFEAREA_H

#include <QMarginsF>
#include <QObject>

#include <qqmlregistration.h>

namespace Kirigami
{

/*!
 * \qmltype SafeArea
 * \inqmlmodule org.kde.kirigami.polyfill
 *
 * \brief A drop-in replacement for Qt's SafeArea attached property
 * when using Qt prior to 6.9. When using Qt 6.9 or higher this type
 * is not provided anymore so the "real" one from Qt gets used instead.
 *
 * Note that this has no actual functionality and will always report
 * zero margins.
 *
 * This is for internal use only and will go away once the minimum Qt version
 * for Kirigami has reached 6.9!
 *
 * \since 6.15
 */
class SafeAreaAttached : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QMarginsF margins READ margins NOTIFY marginsChanged FINAL)

    QML_NAMED_ELEMENT(SafeArea)
    QML_ATTACHED(SafeAreaAttached)
    QML_UNCREATABLE("")

public:
    explicit SafeAreaAttached(QObject *parent);

    [[nodiscard]] QMarginsF margins() const;

    [[nodiscard]] static SafeAreaAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void marginsChanged();
};
}

#endif
