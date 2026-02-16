/*
 *  SPDX-FileCopyrightText: 2026 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "stylehints.h"

#include <QCoreApplication>

namespace Kirigami
{

namespace Platform
{

class KIRIGAMIPLATFORM_NO_EXPORT StyleHints::Private
{
public:
    bool useAlternateBackgroundColor = false;
    bool showFramedBackground = false;
    int tickMarkStepSize = 0;
    QString iconName;
    QUrl iconSource;

    inline static std::function<StyleHints *(QObject *)> s_makeStyleHintsFunction;
};

StyleHints::StyleHints(QObject *parent)
    : QObject(parent)
    , d(std::make_unique<Private>())
{
}

StyleHints::~StyleHints() noexcept
{
}

bool StyleHints::showFramedBackground() const
{
    return d->showFramedBackground;
}

void StyleHints::setShowFramedBackground(bool newShowFramedBackground)
{
    if (newShowFramedBackground == d->showFramedBackground) {
        return;
    }

    d->showFramedBackground = newShowFramedBackground;
    propertyChanged(ChangedProperty::ShowFramedBackground);
    Q_EMIT showFramedBackgroundChanged();
}

int StyleHints::tickMarkStepSize() const
{
    return d->tickMarkStepSize;
}

void StyleHints::setTickMarkStepSize(int newTickMarkStepSize)
{
    if (newTickMarkStepSize == d->tickMarkStepSize) {
        return;
    }

    d->tickMarkStepSize = newTickMarkStepSize;
    propertyChanged(ChangedProperty::TickMarkStepSize);
    Q_EMIT tickMarkStepSizeChanged();
}

QString StyleHints::iconName() const
{
    return d->iconName;
}

void StyleHints::setIconName(const QString &newIconName)
{
    if (newIconName == d->iconName) {
        return;
    }

    d->iconName = newIconName;
    propertyChanged(ChangedProperty::IconName);
    Q_EMIT iconNameChanged();
}

QUrl StyleHints::iconSource() const
{
    return d->iconSource;
}

void StyleHints::setIconSource(const QUrl &newIconSource)
{
    if (newIconSource == d->iconSource) {
        return;
    }

    d->iconSource = newIconSource;
    Q_EMIT iconSourceChanged();
}

StyleHints *StyleHints::qmlAttachedProperties(QObject *object)
{
    if (Private::s_makeStyleHintsFunction) {
        return Private::s_makeStyleHintsFunction(object);
    }

    return new StyleHints(object);
}

void StyleHints::setMakeStyleHintsFunction(const std::function<StyleHints *(QObject *)> &function)
{
    Private::s_makeStyleHintsFunction = function;
}

void StyleHints::propertyChanged([[maybe_unused]] ChangedProperty change)
{
}

}
}
