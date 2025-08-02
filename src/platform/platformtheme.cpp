/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "platformtheme.h"
#include "basictheme_p.h"
#include "platformpluginfactory.h"
#include <QDebug>
#include <QDir>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QPluginLoader>
#include <QPointer>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickStyle>
#include <QQuickWindow>

#include <array>
#include <cinttypes>
#include <functional>
#include <memory>
#include <unordered_map>

namespace Kirigami
{
namespace Platform
{
template<>
KIRIGAMIPLATFORM_EXPORT QEvent::Type PlatformThemeEvents::DataChangedEvent::type = QEvent::None;
template<>
KIRIGAMIPLATFORM_EXPORT QEvent::Type PlatformThemeEvents::ColorSetChangedEvent::type = QEvent::None;
template<>
KIRIGAMIPLATFORM_EXPORT QEvent::Type PlatformThemeEvents::ColorGroupChangedEvent::type = QEvent::None;
template<>
KIRIGAMIPLATFORM_EXPORT QEvent::Type PlatformThemeEvents::ColorChangedEvent::type = QEvent::None;
template<>
KIRIGAMIPLATFORM_EXPORT QEvent::Type PlatformThemeEvents::FontChangedEvent::type = QEvent::None;

// Initialize event types.
// We want to avoid collisions with application event types so we should use
// registerEventType for generating the event types. Unfortunately, that method
// is not constexpr so we need to call it somewhere during application startup.
// This struct handles that.
struct TypeInitializer {
    TypeInitializer()
    {
        PlatformThemeEvents::DataChangedEvent::type = QEvent::Type(QEvent::registerEventType());
        PlatformThemeEvents::ColorSetChangedEvent::type = QEvent::Type(QEvent::registerEventType());
        PlatformThemeEvents::ColorGroupChangedEvent::type = QEvent::Type(QEvent::registerEventType());
        PlatformThemeEvents::ColorChangedEvent::type = QEvent::Type(QEvent::registerEventType());
        PlatformThemeEvents::FontChangedEvent::type = QEvent::Type(QEvent::registerEventType());
    }
};
static TypeInitializer initializer;

// This class encapsulates the actual data of the Theme object. It may be shared
// among several instances of PlatformTheme, to ensure that the memory usage of
// PlatformTheme stays low.
class PlatformThemeData : public QObject
{
    Q_OBJECT

public:
    // An enum for all colors in PlatformTheme.
    // This is used so we can have a QHash of local overrides in the
    // PlatformTheme, which avoids needing to store all these colors in
    // PlatformTheme even when they're not used.
    enum ColorRole {
        TextColor,
        DisabledTextColor,
        HighlightedTextColor,
        ActiveTextColor,
        LinkColor,
        VisitedLinkColor,
        NegativeTextColor,
        NeutralTextColor,
        PositiveTextColor,
        BackgroundColor,
        AlternateBackgroundColor,
        HighlightColor,
        ActiveBackgroundColor,
        LinkBackgroundColor,
        VisitedLinkBackgroundColor,
        NegativeBackgroundColor,
        NeutralBackgroundColor,
        PositiveBackgroundColor,
        FocusColor,
        HoverColor,

        // This should always be the last item. It indicates how many items
        // there are and is used for the storage array below.
        ColorRoleCount,
    };

    using ColorMap = std::unordered_map<std::underlying_type<ColorRole>::type, QColor>;

    // Which PlatformTheme instance "owns" this data object. Only the owner is
    // allowed to make changes to data.
    QPointer<PlatformTheme> owner;

    PlatformTheme::ColorSet colorSet = PlatformTheme::Window;
    PlatformTheme::ColorGroup colorGroup = PlatformTheme::Active;

    std::array<QColor, ColorRoleCount> colors;

    QFont defaultFont;
    QFont smallFont = QFontDatabase::systemFont(QFontDatabase::SmallestReadableFont);
    QFont fixedWidthFont = QFontDatabase::systemFont(QFontDatabase::FixedFont);

    QPalette palette;

    // A list of PlatformTheme instances that want to be notified when the data
    // changes. This is used instead of signal/slots as this way we only store
    // a little bit of data and that data is shared among instances, whereas
    // signal/slots turn out to have a pretty large memory overhead per instance.
    using Watcher = PlatformTheme *;
    QList<Watcher> watchers;

    inline void setColorSet(PlatformTheme *sender, PlatformTheme::ColorSet set)
    {
        if (sender != owner || colorSet == set) {
            return;
        }

        auto oldValue = colorSet;

        colorSet = set;

        notifyWatchers<PlatformTheme::ColorSet>(sender, oldValue, set);
    }

    inline void setColorGroup(PlatformTheme *sender, PlatformTheme::ColorGroup group)
    {
        if (sender != owner || colorGroup == group) {
            return;
        }

        auto oldValue = colorGroup;

        colorGroup = group;
        palette.setCurrentColorGroup(QPalette::ColorGroup(group));

        notifyWatchers<PlatformTheme::ColorGroup>(sender, oldValue, group);
    }

    inline void setColor(PlatformTheme *sender, ColorRole role, const QColor &color)
    {
        if (sender != owner || colors[role] == color) {
            return;
        }

        auto oldValue = colors[role];

        colors[role] = color;
        updatePalette(palette, colors);

        notifyWatchers<QColor>(sender, oldValue, colors[role]);
    }

    inline void setDefaultFont(PlatformTheme *sender, const QFont &font)
    {
        if (sender != owner || font == defaultFont) {
            return;
        }

        auto oldValue = defaultFont;

        defaultFont = font;

        notifyWatchers<QFont>(sender, oldValue, font);
    }

    inline void setSmallFont(PlatformTheme *sender, const QFont &font)
    {
        if (sender != owner || font == smallFont) {
            return;
        }

        auto oldValue = smallFont;

        smallFont = font;

        notifyWatchers<QFont>(sender, oldValue, smallFont);
    }

    inline void setFixedWidthFont(PlatformTheme *sender, const QFont &font)
    {
        if (sender != owner || font == fixedWidthFont) {
            return;
        }

        auto oldValue = fixedWidthFont;

        fixedWidthFont = font;

        notifyWatchers<QFont>(sender, oldValue, fixedWidthFont);
    }

    inline void addChangeWatcher(PlatformTheme *object)
    {
        watchers.append(object);
    }

    inline void removeChangeWatcher(PlatformTheme *object)
    {
        watchers.removeOne(object);
    }

    template<typename T>
    inline void notifyWatchers(PlatformTheme *sender, const T &oldValue, const T &newValue)
    {
        for (auto object : std::as_const(watchers)) {
            PlatformThemeEvents::PropertyChangedEvent<T> event(sender, oldValue, newValue);
            QCoreApplication::sendEvent(object, &event);
        }
    }

    // Update a palette from a list of colors.
    inline static void updatePalette(QPalette &palette, const std::array<QColor, ColorRoleCount> &colors)
    {
        for (std::size_t i = 0; i < colors.size(); ++i) {
            setPaletteColor(palette, ColorRole(i), colors.at(i));
        }
    }

    // Update a palette from a hash of colors.
    inline static void updatePalette(QPalette &palette, const ColorMap &colors)
    {
        for (auto entry : colors) {
            setPaletteColor(palette, ColorRole(entry.first), entry.second);
        }
    }

    inline static void setPaletteColor(QPalette &palette, ColorRole role, const QColor &color)
    {
        switch (role) {
        case TextColor:
            palette.setColor(QPalette::Text, color);
            palette.setColor(QPalette::WindowText, color);
            palette.setColor(QPalette::ButtonText, color);
            break;
        case BackgroundColor:
            palette.setColor(QPalette::Window, color);
            palette.setColor(QPalette::Base, color);
            palette.setColor(QPalette::Button, color);
            break;
        case AlternateBackgroundColor:
            palette.setColor(QPalette::AlternateBase, color);
            break;
        case HighlightColor:
            palette.setColor(QPalette::Highlight, color);
            palette.setColor(QPalette::Accent, color);
            break;
        case HighlightedTextColor:
            palette.setColor(QPalette::HighlightedText, color);
            break;
        case LinkColor:
            palette.setColor(QPalette::Link, color);
            break;
        case VisitedLinkColor:
            palette.setColor(QPalette::LinkVisited, color);
            break;

        default:
            break;
        }
    }
};

class PlatformThemePrivate
{
public:
    PlatformThemePrivate()
        : inherit(true)
        , supportsIconColoring(false)
        , pendingColorChange(false)
        , pendingChildUpdate(false)
        , useAlternateBackgroundColor(false)
        , colorSet(PlatformTheme::Window)
        , colorGroup(PlatformTheme::Active)
    {
    }

    inline QColor color(const PlatformTheme *theme, PlatformThemeData::ColorRole color) const
    {
        if (!data) {
            return QColor{};
        }

        QColor value = data->colors.at(color);

        if (data->owner != theme && localOverrides) {
            auto itr = localOverrides->find(color);
            if (itr != localOverrides->end()) {
                value = itr->second;
            }
        }

        return value;
    }

    inline void setColor(PlatformTheme *theme, PlatformThemeData::ColorRole color, const QColor &value)
    {
        if (!localOverrides) {
            localOverrides = std::make_unique<PlatformThemeData::ColorMap>();
        }

        if (!value.isValid()) {
            // Invalid color, assume we are resetting the value.
            auto itr = localOverrides->find(color);
            if (itr != localOverrides->end()) {
                PlatformThemeChangeTracker tracker(theme, PlatformThemeChangeTracker::PropertyChange::Color);
                localOverrides->erase(itr);

                if (data) {
                    // TODO: Find a better way to determine "default" color.
                    // Right now this sets the color to transparent to force a
                    // color change and relies on the style-specific subclass to
                    // handle resetting the actual color.
                    data->setColor(theme, color, Qt::transparent);
                }
            }

            return;
        }

        auto itr = localOverrides->find(color);
        if (itr != localOverrides->end() && itr->second == value && (data && data->owner != theme)) {
            return;
        }

        PlatformThemeChangeTracker tracker(theme, PlatformThemeChangeTracker::PropertyChange::Color);

        (*localOverrides)[color] = value;

        if (data) {
            data->setColor(theme, color, value);
        }
    }

    inline void setDataColor(PlatformTheme *theme, PlatformThemeData::ColorRole color, const QColor &value)
    {
        // Only set color if we have no local override of the color.
        // This is done because colorSet/colorGroup changes will trigger most
        // subclasses to reevaluate and reset the colors, breaking any local
        // overrides we have.
        if (localOverrides) {
            auto itr = localOverrides->find(color);
            if (itr != localOverrides->end()) {
                return;
            }
        }

        PlatformThemeChangeTracker tracker(theme, PlatformThemeChangeTracker::PropertyChange::Color);

        if (data) {
            data->setColor(theme, color, value);
        }
    }

    /*
     * Please note that there is no q pointer. This is intentional, as it avoids
     * having to store that information for each instance of PlatformTheme,
     * saving us 8 bytes per instance. Instead, we pass the theme object as
     * first parameter of each method. This is a little uglier but essentially
     * works the same without needing memory.
     */

    // An instance of the data object. This is potentially shared with many
    // instances of PlatformTheme.
    std::shared_ptr<PlatformThemeData> data;
    // Used to store color overrides of inherited data. This is created on
    // demand and will only exist if we actually have local overrides.
    std::unique_ptr<PlatformThemeData::ColorMap> localOverrides;

    bool inherit : 1;
    bool supportsIconColoring : 1; // TODO KF6: Remove in favour of virtual method
    bool pendingColorChange : 1;
    bool pendingChildUpdate : 1;
    bool useAlternateBackgroundColor : 1;
    bool isConstructing : 1 = false;

    // Note: We use these to store local values of PlatformTheme::ColorSet and
    // PlatformTheme::ColorGroup. While these are standard enums and thus 32
    // bits they only contain a few items so we store the value in only 4 bits
    // to save space.
    uint8_t colorSet : 4;
    uint8_t colorGroup : 4;

    // Ensure the above assumption holds. Should this static assert fail, the
    // bit size above needs to be adjusted.
    static_assert(PlatformTheme::ColorGroupCount <= 16, "PlatformTheme::ColorGroup contains more elements than can be stored in PlatformThemePrivate");
    static_assert(PlatformTheme::ColorSetCount <= 16, "PlatformTheme::ColorSet contains more elements than can be stored in PlatformThemePrivate");

    inline static PlatformPluginFactory *s_pluginFactory = nullptr;
};

PlatformTheme::PlatformTheme(QObject *parent)
    : QObject(parent)
    , d(new PlatformThemePrivate)
{
    setConstructing(true);
    if (QQuickItem *item = qobject_cast<QQuickItem *>(parent)) {
        connect(item, &QQuickItem::windowChanged, this, [this](QQuickWindow *window) {
            if (window) {
                update();
            }
        });
        connect(item, &QQuickItem::parentChanged, this, &PlatformTheme::update);
        // Needs to be connected to enabledChanged twice to correctly fully update when a
        // Theme that does inherit becomes temporarly non-inherit and back due to
        // the item being enabled or disabled
        connect(item, &QQuickItem::enabledChanged, this, &PlatformTheme::update);
        connect(item, &QQuickItem::enabledChanged, this, &PlatformTheme::update, Qt::QueuedConnection);
    }

    update();
    setConstructing(false);
}

PlatformTheme::~PlatformTheme()
{
    if (d->data) {
        d->data->removeChangeWatcher(this);
    }

    delete d;
}

void PlatformTheme::setColorSet(PlatformTheme::ColorSet colorSet)
{
    PlatformThemeChangeTracker tracker(this, PlatformThemeChangeTracker::PropertyChange::ColorSet);
    d->colorSet = colorSet;

    if (d->data) {
        d->data->setColorSet(this, colorSet);
    }
}

PlatformTheme::ColorSet PlatformTheme::colorSet() const
{
    return d->data ? d->data->colorSet : Window;
}

void PlatformTheme::setColorGroup(PlatformTheme::ColorGroup colorGroup)
{
    PlatformThemeChangeTracker tracker(this, PlatformThemeChangeTracker::PropertyChange::ColorGroup);
    d->colorGroup = colorGroup;

    if (d->data) {
        d->data->setColorGroup(this, colorGroup);
    }
}

PlatformTheme::ColorGroup PlatformTheme::colorGroup() const
{
    return d->data ? d->data->colorGroup : Active;
}

bool PlatformTheme::inherit() const
{
    return d->inherit;
}

void PlatformTheme::setInherit(bool inherit)
{
    if (inherit == d->inherit) {
        return;
    }

    d->inherit = inherit;
    update();

    Q_EMIT inheritChanged(inherit);
}

QColor PlatformTheme::textColor() const
{
    return d->color(this, PlatformThemeData::TextColor);
}

QColor PlatformTheme::disabledTextColor() const
{
    return d->color(this, PlatformThemeData::DisabledTextColor);
}

QColor PlatformTheme::highlightColor() const
{
    return d->color(this, PlatformThemeData::HighlightColor);
}

QColor PlatformTheme::highlightedTextColor() const
{
    return d->color(this, PlatformThemeData::HighlightedTextColor);
}

QColor PlatformTheme::backgroundColor() const
{
    return d->color(this, PlatformThemeData::BackgroundColor);
}

QColor PlatformTheme::alternateBackgroundColor() const
{
    return d->color(this, PlatformThemeData::AlternateBackgroundColor);
}

QColor PlatformTheme::activeTextColor() const
{
    return d->color(this, PlatformThemeData::ActiveTextColor);
}

QColor PlatformTheme::activeBackgroundColor() const
{
    return d->color(this, PlatformThemeData::ActiveBackgroundColor);
}

QColor PlatformTheme::linkColor() const
{
    return d->color(this, PlatformThemeData::LinkColor);
}

QColor PlatformTheme::linkBackgroundColor() const
{
    return d->color(this, PlatformThemeData::LinkBackgroundColor);
}

QColor PlatformTheme::visitedLinkColor() const
{
    return d->color(this, PlatformThemeData::VisitedLinkColor);
}

QColor PlatformTheme::visitedLinkBackgroundColor() const
{
    return d->color(this, PlatformThemeData::VisitedLinkBackgroundColor);
}

QColor PlatformTheme::negativeTextColor() const
{
    return d->color(this, PlatformThemeData::NegativeTextColor);
}

QColor PlatformTheme::negativeBackgroundColor() const
{
    return d->color(this, PlatformThemeData::NegativeBackgroundColor);
}

QColor PlatformTheme::neutralTextColor() const
{
    return d->color(this, PlatformThemeData::NeutralTextColor);
}

QColor PlatformTheme::neutralBackgroundColor() const
{
    return d->color(this, PlatformThemeData::NeutralBackgroundColor);
}

QColor PlatformTheme::positiveTextColor() const
{
    return d->color(this, PlatformThemeData::PositiveTextColor);
}

QColor PlatformTheme::positiveBackgroundColor() const
{
    return d->color(this, PlatformThemeData::PositiveBackgroundColor);
}

QColor PlatformTheme::focusColor() const
{
    return d->color(this, PlatformThemeData::FocusColor);
}

QColor PlatformTheme::hoverColor() const
{
    return d->color(this, PlatformThemeData::HoverColor);
}

// setters for theme implementations
void PlatformTheme::setTextColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::TextColor, color);
}

void PlatformTheme::setDisabledTextColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::DisabledTextColor, color);
}

void PlatformTheme::setBackgroundColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::BackgroundColor, color);
}

void PlatformTheme::setAlternateBackgroundColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::AlternateBackgroundColor, color);
}

void PlatformTheme::setHighlightColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::HighlightColor, color);
}

void PlatformTheme::setHighlightedTextColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::HighlightedTextColor, color);
}

void PlatformTheme::setActiveTextColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::ActiveTextColor, color);
}

void PlatformTheme::setActiveBackgroundColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::ActiveBackgroundColor, color);
}

void PlatformTheme::setLinkColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::LinkColor, color);
}

void PlatformTheme::setLinkBackgroundColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::LinkBackgroundColor, color);
}

void PlatformTheme::setVisitedLinkColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::VisitedLinkColor, color);
}

void PlatformTheme::setVisitedLinkBackgroundColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::VisitedLinkBackgroundColor, color);
}

void PlatformTheme::setNegativeTextColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::NegativeTextColor, color);
}

void PlatformTheme::setNegativeBackgroundColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::NegativeBackgroundColor, color);
}

void PlatformTheme::setNeutralTextColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::NeutralTextColor, color);
}

void PlatformTheme::setNeutralBackgroundColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::NeutralBackgroundColor, color);
}

void PlatformTheme::setPositiveTextColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::PositiveTextColor, color);
}

void PlatformTheme::setPositiveBackgroundColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::PositiveBackgroundColor, color);
}

void PlatformTheme::setHoverColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::HoverColor, color);
}

void PlatformTheme::setFocusColor(const QColor &color)
{
    d->setDataColor(this, PlatformThemeData::FocusColor, color);
}

QFont PlatformTheme::defaultFont() const
{
    return d->data ? d->data->defaultFont : QFont{};
}

void PlatformTheme::setDefaultFont(const QFont &font)
{
    PlatformThemeChangeTracker tracker(this, PlatformThemeChangeTracker::PropertyChange::Font);
    if (d->data) {
        d->data->setDefaultFont(this, font);
    }
}

QFont PlatformTheme::smallFont() const
{
    return d->data ? d->data->smallFont : QFont{};
}

void PlatformTheme::setSmallFont(const QFont &font)
{
    PlatformThemeChangeTracker tracker(this, PlatformThemeChangeTracker::PropertyChange::Font);
    if (d->data) {
        d->data->setSmallFont(this, font);
    }
}

QFont PlatformTheme::fixedWidthFont() const
{
    return d->data ? d->data->fixedWidthFont : QFont{};
}

void PlatformTheme::setFixedWidthFont(const QFont &font)
{
    PlatformThemeChangeTracker tracker(this, PlatformThemeChangeTracker::PropertyChange::Font);
    if (d->data) {
        d->data->setFixedWidthFont(this, font);
    }
}

qreal PlatformTheme::frameContrast() const
{
    // This value must be kept in sync with
    // the value from Breeze Qt Widget theme.
    // See: https://invent.kde.org/plasma/breeze/-/blob/master/kstyle/breezemetrics.h?ref_type=heads#L162
    return 0.20;
}

qreal PlatformTheme::lightFrameContrast() const
{
    // This can be utilized to return full contrast
    // if high contrast accessibility setting is enabled
    return frameContrast() / 2.0;
}

// setters for QML clients
void PlatformTheme::setCustomTextColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::TextColor, color);
}

void PlatformTheme::setCustomDisabledTextColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::DisabledTextColor, color);
}

void PlatformTheme::setCustomBackgroundColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::BackgroundColor, color);
}

void PlatformTheme::setCustomAlternateBackgroundColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::AlternateBackgroundColor, color);
}

void PlatformTheme::setCustomHighlightColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::HighlightColor, color);
}

void PlatformTheme::setCustomHighlightedTextColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::HighlightedTextColor, color);
}

void PlatformTheme::setCustomActiveTextColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::ActiveTextColor, color);
}

void PlatformTheme::setCustomActiveBackgroundColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::ActiveBackgroundColor, color);
}

void PlatformTheme::setCustomLinkColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::LinkColor, color);
}

void PlatformTheme::setCustomLinkBackgroundColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::LinkBackgroundColor, color);
}

void PlatformTheme::setCustomVisitedLinkColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::TextColor, color);
}

void PlatformTheme::setCustomVisitedLinkBackgroundColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::VisitedLinkBackgroundColor, color);
}

void PlatformTheme::setCustomNegativeTextColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::NegativeTextColor, color);
}

void PlatformTheme::setCustomNegativeBackgroundColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::NegativeBackgroundColor, color);
}

void PlatformTheme::setCustomNeutralTextColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::NeutralTextColor, color);
}

void PlatformTheme::setCustomNeutralBackgroundColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::NeutralBackgroundColor, color);
}

void PlatformTheme::setCustomPositiveTextColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::PositiveTextColor, color);
}

void PlatformTheme::setCustomPositiveBackgroundColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::PositiveBackgroundColor, color);
}

void PlatformTheme::setCustomHoverColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::HoverColor, color);
}

void PlatformTheme::setCustomFocusColor(const QColor &color)
{
    d->setColor(this, PlatformThemeData::FocusColor, color);
}

bool PlatformTheme::useAlternateBackgroundColor() const
{
    return d->useAlternateBackgroundColor;
}

void PlatformTheme::setUseAlternateBackgroundColor(bool alternate)
{
    if (alternate == d->useAlternateBackgroundColor) {
        return;
    }

    d->useAlternateBackgroundColor = alternate;
    Q_EMIT useAlternateBackgroundColorChanged(alternate);
}

QPalette PlatformTheme::palette() const
{
    if (!d->data) {
        return QPalette{};
    }

    auto palette = d->data->palette;

    if (d->localOverrides) {
        PlatformThemeData::updatePalette(palette, *d->localOverrides);
    }

    return palette;
}

QIcon PlatformTheme::iconFromTheme(const QString &name, const QColor &customColor)
{
    Q_UNUSED(customColor);
    QIcon icon = QIcon::fromTheme(name);
    return icon;
}

bool PlatformTheme::supportsIconColoring() const
{
    return d->supportsIconColoring;
}

void PlatformTheme::setConstructing(bool isConstructing)
{
    d->isConstructing = isConstructing;
}

void PlatformTheme::setSupportsIconColoring(bool support)
{
    d->supportsIconColoring = support;
}

PlatformTheme *PlatformTheme::qmlAttachedProperties(QObject *object)
{
    QQmlEngine *engine = qmlEngine(object);
    QString pluginName;

    if (engine) {
        pluginName = engine->property("_kirigamiTheme").toString();
    }

    auto plugin = PlatformPluginFactory::findPlugin(pluginName);
    if (!plugin && !pluginName.isEmpty()) {
        plugin = PlatformPluginFactory::findPlugin();
    }

    if (plugin) {
        if (auto theme = plugin->createPlatformTheme(object)) {
            return theme;
        }
    }

    return new BasicTheme(object);
}

void PlatformTheme::emitSignalsForChanges(int changes)
{
    if (!d->data) {
        return;
    }

    auto propertyChanges = PlatformThemeChangeTracker::PropertyChanges::fromInt(changes);

    if (propertyChanges & PlatformThemeChangeTracker::PropertyChange::ColorSet) {
        Q_EMIT colorSetChanged(ColorSet(d->data->colorSet));
    }

    if (propertyChanges & PlatformThemeChangeTracker::PropertyChange::ColorGroup) {
        Q_EMIT colorGroupChanged(ColorGroup(d->data->colorGroup));
    }

    if (propertyChanges & PlatformThemeChangeTracker::PropertyChange::Color) {
        Q_EMIT colorsChanged();
    }

    if (propertyChanges & PlatformThemeChangeTracker::PropertyChange::Palette) {
        Q_EMIT paletteChanged(d->data->palette);
    }

    if (propertyChanges & PlatformThemeChangeTracker::PropertyChange::Font) {
        Q_EMIT defaultFontChanged(d->data->defaultFont);
        Q_EMIT smallFontChanged(d->data->smallFont);
        Q_EMIT fixedWidthFontChanged(d->data->fixedWidthFont);
    }

    if (propertyChanges & PlatformThemeChangeTracker::PropertyChange::Data) {
        updateChildren(parent());
    }
}

bool PlatformTheme::event(QEvent *event)
{
    PlatformThemeChangeTracker tracker(this);

    if (event->type() == PlatformThemeEvents::DataChangedEvent::type) {
        auto changeEvent = static_cast<PlatformThemeEvents::DataChangedEvent *>(event);

        if (changeEvent->sender != this) {
            return false;
        }

        if (changeEvent->oldValue) {
            changeEvent->oldValue->removeChangeWatcher(this);
        }

        if (changeEvent->newValue) {
            auto data = changeEvent->newValue;
            data->addChangeWatcher(this);
        }

        tracker.markDirty(PlatformThemeChangeTracker::PropertyChange::All);
        return true;
    }

    if (event->type() == PlatformThemeEvents::ColorSetChangedEvent::type) {
        tracker.markDirty(PlatformThemeChangeTracker::PropertyChange::ColorSet);
        return true;
    }

    if (event->type() == PlatformThemeEvents::ColorGroupChangedEvent::type) {
        tracker.markDirty(PlatformThemeChangeTracker::PropertyChange::ColorGroup);
        return true;
    }

    if (event->type() == PlatformThemeEvents::ColorChangedEvent::type) {
        tracker.markDirty(PlatformThemeChangeTracker::PropertyChange::Color | PlatformThemeChangeTracker::PropertyChange::Palette);
        return true;
    }

    if (event->type() == PlatformThemeEvents::FontChangedEvent::type) {
        tracker.markDirty(PlatformThemeChangeTracker::PropertyChange::Font);
        return true;
    }

    return QObject::event(event);
}

void PlatformTheme::update()
{
    auto oldData = d->data;

    bool actualInherit = d->inherit;
    if (QQuickItem *item = qobject_cast<QQuickItem *>(parent())) {
        // For inactive windows it should work already, as also the non inherit themes get it
        if (colorGroup() != Disabled && !item->isEnabled()) {
            actualInherit = false;
        }
    }

    if (actualInherit) {
        QObject *candidate = parent();
        while (true) {
            candidate = determineParent(candidate);
            if (!candidate) {
                break;
            }

            auto t = static_cast<PlatformTheme *>(qmlAttachedPropertiesObject<PlatformTheme>(candidate, false));
            if (t && t->d->data && t->d->data->owner == t) {
                if (d->data == t->d->data) {
                    // Inheritance is already correct, do nothing.
                    return;
                }

                d->data = t->d->data;

                PlatformThemeEvents::DataChangedEvent event{this, oldData, t->d->data};
                QCoreApplication::sendEvent(this, &event);

                return;
            }
        }
    } else if (d->data && d->data->owner != this) {
        // Inherit has changed and we no longer want to inherit, clear the data
        // so it is recreated below.
        d->data = nullptr;
    }

    if (!d->data) {
        d->data = std::make_shared<PlatformThemeData>();
        d->data->owner = this;

        d->data->setColorSet(this, static_cast<ColorSet>(d->colorSet));
        d->data->setColorGroup(this, static_cast<ColorGroup>(d->colorGroup));

        // If we normally inherit but do not do so currently due to an override,
        // copy over the old colorSet to ensure we do not suddenly change to a
        // different colorSet.
        if (d->inherit && !actualInherit && oldData) {
            d->data->setColorSet(this, oldData->colorSet);
        }
    }

    if (d->localOverrides) {
        for (auto entry : *d->localOverrides) {
            d->data->setColor(this, PlatformThemeData::ColorRole(entry.first), entry.second);
        }
    }

    PlatformThemeEvents::DataChangedEvent event{this, oldData, d->data};
    QCoreApplication::sendEvent(this, &event);
}

void PlatformTheme::updateChildren(QObject *object)
{
    if (!object) {
        return;
    }

    const auto children = object->children();
    for (auto child : children) {
        auto t = static_cast<PlatformTheme *>(qmlAttachedPropertiesObject<PlatformTheme>(child, false));
        if (t) {
            t->update();
        } else {
            updateChildren(child);
        }
    }
}

// We sometimes set theme properties on non-visual objects. However, if an item
// has a visual and a non-visual parent that are different, we should prefer the
// visual parent, so we need to apply some extra logic.
QObject *PlatformTheme::determineParent(QObject *object)
{
    if (!object) {
        return nullptr;
    }

    auto item = qobject_cast<QQuickItem *>(object);
    if (item) {
        return item->parentItem();
    } else {
        return object->parent();
    }
}

PlatformThemeChangeTracker::PlatformThemeChangeTracker(PlatformTheme *theme, PropertyChanges changes)
    : m_theme(theme)
{
    auto itr = s_blockedChanges.constFind(theme);
    if (itr == s_blockedChanges.constEnd() || (*itr).expired()) {
        m_data = std::make_shared<Data>();
        s_blockedChanges.insert(theme, m_data);
    } else {
        m_data = (*itr).lock();
    }

    m_data->changes |= changes;
}

PlatformThemeChangeTracker::~PlatformThemeChangeTracker() noexcept
{
    std::weak_ptr<Data> dataWatcher = m_data;

    auto changes = m_data->changes;
    m_data.reset();

    if (dataWatcher.use_count() <= 0) {
        if (!m_theme->d->isConstructing) {
            m_theme->emitSignalsForChanges(changes);
        }
        s_blockedChanges.remove(m_theme);
    }
}

void PlatformThemeChangeTracker::markDirty(PropertyChanges changes)
{
    m_data->changes |= changes;
}
}
}

#include "moc_platformtheme.cpp"
#include "platformtheme.moc"
