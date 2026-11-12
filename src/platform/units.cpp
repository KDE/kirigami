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
#include <QQuickStyle>
#include <QStyleHints>

#include <chrono>
#include <cmath>

#include "kirigamiplatform_logging.h"
#include "platformpluginfactory.h"

namespace Kirigami
{
namespace Platform
{

class UnitsPrivate
{
    Q_DISABLE_COPY(UnitsPrivate)

public:
    explicit UnitsPrivate(Units *units)
        // Cache font so we don't have to go through QVariant and property every time
        : fontMetrics(QFontMetricsF(QGuiApplication::font()))
        , gridUnit(18)
        , smallSpacing(4)
        , mediumSpacing(6)
        , largeSpacing(8)
        , veryLongDuration(400)
        , longDuration(200)
        , shortDuration(100)
        , veryShortDuration(50)
        , humanMoment(2000)
        , toolTipDelay(700)
        , cornerRadius(5)
        , maximumParagraphWidth(fontMetrics.horizontalAdvance(QString(80, u'0')))
        , iconSizes(new IconSizes(units))
    {
    }

    // Font metrics used for Units.
    // TextMetrics uses QFontMetricsF internally, so this should do the same
    QFontMetricsF fontMetrics;

    int gridUnit;
    int smallSpacing;
    int mediumSpacing;
    int largeSpacing;
    int veryLongDuration;
    int longDuration;
    int shortDuration;
    int veryShortDuration;
    int humanMoment;
    int toolTipDelay;
    qreal cornerRadius;
    int maximumParagraphWidth;

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

void Units::setGridUnit(int size)
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

void Units::setSmallSpacing(int size)
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

void Units::setMediumSpacing(int size)
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

void Units::setLargeSpacing(int size)
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

qreal Units::cornerRadius() const
{
    return d->cornerRadius;
}

void Units::setcornerRadius(qreal cornerRadius)
{
    if (d->cornerRadius == cornerRadius) {
        return;
    }

    d->cornerRadius = cornerRadius;
    Q_EMIT cornerRadiusChanged();
}

int Units::maximumParagraphWidth() const
{
    return d->maximumParagraphWidth;
}

void Units::setMaximumParagraphWidth(int size)
{
    if (d->maximumParagraphWidth == size) {
        return;
    }

    d->maximumParagraphWidth = size;
    d->customUnitsSet = true;
    Q_EMIT maximumParagraphWidthChanged();
}

Units *Units::create(QQmlEngine *qmlEngine, [[maybe_unused]] QJSEngine *jsEngine)
{
#ifndef KIRIGAMI_BUILD_TYPE_STATIC
    const QString pluginName = qmlEngine->property("_kirigamiTheme").toString();

    auto plugin = PlatformPluginFactory::findPlugin(pluginName);
    if (!plugin && !pluginName.isEmpty()) {
        plugin = PlatformPluginFactory::findPlugin();
    }

    if (plugin) {
        return plugin->createUnits(qmlEngine);
    }
#endif
    // Fall back to the default units implementation
    return new Units(qmlEngine);
}

bool Units::eventFilter([[maybe_unused]] QObject *watched, QEvent *event)
{
    if ((event->type() == QEvent::ApplicationFontChange) && (watched == qGuiApp)) {
        d->fontMetrics = QFontMetricsF(qGuiApp->font());

        if (d->customUnitsSet) {
            return false;
        }

        d->maximumParagraphWidth = d->fontMetrics.horizontalAdvance(QString(80, u'0'));

        Q_EMIT d->iconSizes->sizeForLabelsChanged();
        Q_EMIT maximumParagraphWidthChanged();
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
}

#include "moc_units.cpp"
