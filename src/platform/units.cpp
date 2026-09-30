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
#include <QIcon>
#include <QQmlComponent>
#include <QQuickStyle>
#include <QStyleHints>

#include <chrono>
#include <cmath>

#include "kirigamiplatform_logging.h"
#include "platformpluginfactory.h"

using namespace Qt::StringLiterals;

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
    qreal cornerRadius;

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
    // TODO: this might have to be redone when t he icon theme changes at runtime
    const auto icon = QIcon::fromTheme(u"folder"_s);
    const auto availableSizes = icon.availableSizes();
    for (auto size : {Small, SmallMedium, Medium, Large, Huge, Enormous}) {
        const int target = static_cast<int>(size);
        auto it = std::ranges::min_element(availableSizes, [target](const QSize &a, const QSize &b) {
            return std::abs(a.width() - target) < std::abs(b.width() - target);
        });

        if (it != availableSizes.end()) {
            m_sizes[size] = it->width();
        }
    }
    qWarning() << m_sizes;
}

int IconSizes::roundedIconSize(int initialSize) const
{
    if (initialSize < m_sizes.value(Small)) {
        return initialSize;
    }

    int closestSize = 0;
    for (const int size : m_sizes) {
        if (size < initialSize) {
            closestSize = std::max(closestSize, size);
        }
    }

    return closestSize;
}

int IconSizes::sizeForLabels() const
{
    // gridUnit is the height of textMetrics
    return roundedIconSize(m_units->d->fontMetrics.height());
}

int IconSizes::small() const
{
    return m_sizes.value(Small);
}

int IconSizes::smallMedium() const
{
    return m_sizes.value(SmallMedium);
}

int IconSizes::medium() const
{
    return m_sizes.value(Medium);
}

int IconSizes::large() const
{
    return m_sizes.value(Large);
}

int IconSizes::huge() const
{
    return m_sizes.value(Huge);
}

int IconSizes::enormous() const
{
    return m_sizes.value(Enormous);
}
}
}

#include "moc_units.cpp"
