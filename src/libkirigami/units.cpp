/*
 *  SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "units.h"

#include <QFont>
#include <QFontMetrics>
#include <QGuiApplication>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QStyleHints>

#include <chrono>
#include <cmath>

#include "loggingcategory.h"

namespace Kirigami
{

class UnitsPrivate
{
    Q_DISABLE_COPY(UnitsPrivate)

public:
    explicit UnitsPrivate(Units *units)
        // Cache font so we don't have to go through QVariant and property every time
        : fontMetrics(QFontMetricsF(QGuiApplication::font()))
        , gridUnit(fontMetrics.height())
        , smallSpacing(std::floor(gridUnit / 4))
        , mediumSpacing(std::round(smallSpacing * 1.5))
        , largeSpacing(smallSpacing * 2)
        , veryLongDuration(400)
        , longDuration(200)
        , shortDuration(100)
        , veryShortDuration(50)
        , humanMoment(2000)
        , toolTipDelay(700)
        , iconSizes(new IconSizes(units))
    {
    }

    // Font metrics used for Units.
    // TextMetrics uses QFontMetricsF internally, so this should do the same
    QFontMetricsF fontMetrics;

    // units
    int gridUnit;
    int smallSpacing;
    int mediumSpacing;
    int largeSpacing;

    // durations
    int veryLongDuration;
    int longDuration;
    int shortDuration;
    int veryShortDuration;
    int humanMoment;
    int toolTipDelay;

    IconSizes *const iconSizes;

    // To prevent overriding custom set units if the font changes
    bool customUnitsSet = false;
};

Units::~Units() = default;

Units::Units(QObject *parent)
    : QObject(parent)
    , d(std::make_unique<UnitsPrivate>(this))
{
    qGuiApp->installEventFilter(this);
}

int Units::gridUnit() const
{
    return d->gridUnit;
}

void Kirigami::Units::setGridUnit(int size)
{
    if (d->gridUnit == size) {
        return;
    }

    d->gridUnit = size;
    d->customUnitsSet = true;
    Q_EMIT gridUnitChanged();
}

int Units::smallSpacing() const
{
    return d->smallSpacing;
}

void Kirigami::Units::setSmallSpacing(int size)
{
    if (d->smallSpacing == size) {
        return;
    }

    d->smallSpacing = size;
    d->customUnitsSet = true;
    Q_EMIT smallSpacingChanged();
}

int Units::mediumSpacing() const
{
    return d->mediumSpacing;
}

void Kirigami::Units::setMediumSpacing(int size)
{
    if (d->mediumSpacing == size) {
        return;
    }

    d->mediumSpacing = size;
    d->customUnitsSet = true;
    Q_EMIT mediumSpacingChanged();
}

int Units::largeSpacing() const
{
    return d->largeSpacing;
}

void Kirigami::Units::setLargeSpacing(int size)
{
    if (d->largeSpacing) {
        return;
    }

    d->largeSpacing = size;
    d->customUnitsSet = true;
    Q_EMIT largeSpacingChanged();
}

int Units::veryLongDuration() const
{
    return d->veryLongDuration;
}

void Units::setVeryLongDuration(int duration)
{
    if (d->veryLongDuration == duration) {
        return;
    }

    d->veryLongDuration = duration;
    Q_EMIT veryLongDurationChanged();
}

int Units::longDuration() const
{
    return d->longDuration;
}

void Units::setLongDuration(int duration)
{
    if (d->longDuration == duration) {
        return;
    }

    d->longDuration = duration;
    Q_EMIT longDurationChanged();
}

int Units::shortDuration() const
{
    return d->shortDuration;
}

void Units::setShortDuration(int duration)
{
    if (d->shortDuration == duration) {
        return;
    }

    d->shortDuration = duration;
    Q_EMIT shortDurationChanged();
}

int Units::veryShortDuration() const
{
    return d->veryShortDuration;
}

void Units::setVeryShortDuration(int duration)
{
    if (d->veryShortDuration == duration) {
        return;
    }

    d->veryShortDuration = duration;
    Q_EMIT veryShortDurationChanged();
}

int Units::humanMoment() const
{
    return d->humanMoment;
}

void Units::setHumanMoment(int duration)
{
    if (d->humanMoment == duration) {
        return;
    }

    d->humanMoment = duration;
    Q_EMIT humanMomentChanged();
}

int Units::toolTipDelay() const
{
    return d->toolTipDelay;
}

void Units::setToolTipDelay(int delay)
{
    if (d->toolTipDelay == delay) {
        return;
    }

    d->toolTipDelay = delay;
    Q_EMIT toolTipDelayChanged();
}

int Units::maximumInteger() const
{
    return std::numeric_limits<int>::max();
}

bool Units::eventFilter([[maybe_unused]] QObject *watched, QEvent *event)
{
    if (event->type() == QEvent::ApplicationFontChange) {
        d->fontMetrics = QFontMetricsF(qGuiApp->font());

        if (d->customUnitsSet) {
            return false;
        }

        d->gridUnit = d->fontMetrics.height();
        Q_EMIT gridUnitChanged();
        d->smallSpacing = std::floor(d->gridUnit / 4);
        Q_EMIT smallSpacingChanged();
        d->mediumSpacing = std::round(d->smallSpacing * 1.5);
        Q_EMIT mediumSpacingChanged();
        d->largeSpacing = d->smallSpacing * 2;
        Q_EMIT largeSpacingChanged();
        Q_EMIT d->iconSizes->sizeForLabelsChanged();
    }
    return false;
}

IconSizes *Units::iconSizes() const
{
    return d->iconSizes;
}

IconSizes::IconSizes(Units *units)
    : QObject(units)
    , m_units(units)
{
}

int IconSizes::roundedIconSize(int size) const
{
    if (size < 16) {
        return size;
    }

    if (size < 22) {
        return 16;
    }

    if (size < 32) {
        return 22;
    }

    if (size < 48) {
        return 32;
    }

    if (size < 64) {
        return 48;
    }

    return size;
}

int IconSizes::sizeForLabels() const
{
    // gridUnit is the height of textMetrics
    return roundedIconSize(m_units->d->fontMetrics.height());
}

int IconSizes::small() const
{
    return 16;
}

int IconSizes::smallMedium() const
{
    return 22;
}

int IconSizes::medium() const
{
    return 32;
}

int IconSizes::large() const
{
    return 48;
}

int IconSizes::huge() const
{
    return 64;
}

int IconSizes::enormous() const
{
    return 128;
}

}
