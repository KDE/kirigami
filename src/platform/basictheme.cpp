/*
 * SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "basictheme_p.h"
#include "styleselector.h"

#include <QFile>
#include <QFontDatabase>
#include <QGuiApplication>

#include "kirigamiplatform_logging.h"

namespace Kirigami
{
namespace Platform
{

BasicThemeDefinition::BasicThemeDefinition(QObject *parent)
    : QObject(parent)
{
    defaultFont = qGuiApp->font();

    smallFont = QFontDatabase::systemFont(QFontDatabase::SmallestReadableFont);
}

void BasicThemeDefinition::syncToQml(PlatformTheme *object)
{
    auto item = qobject_cast<QQuickItem *>(object->parent());
    if (item && qmlAttachedPropertiesObject<PlatformTheme>(item, false) == object) {
        Q_EMIT sync(item);
    }
}

BasicThemeInstance::BasicThemeInstance(QObject *parent)
    : QObject(parent)
{
}

BasicThemeDefinition &BasicThemeInstance::themeDefinition(QQmlEngine *engine)
{
    if (m_themeDefinition) {
        return *m_themeDefinition;
    }

    if (!engine) {
        qCWarning(KirigamiPlatform) << "No QML engine found, using default Basic theme.";
        m_themeDefinition = std::make_unique<BasicThemeDefinition>();
    } else {
        auto themeUrl = StyleSelector::componentUrlForModule(QStringLiteral("controls"), QStringLiteral("Theme.qml"));

        if (themeUrl.isValid()) {
            QQmlComponent component(engine);
            component.loadUrl(themeUrl);

            if (auto themeDefinition = qobject_cast<BasicThemeDefinition *>(component.create())) {
                m_themeDefinition.reset(themeDefinition);
            } else {
                const auto errors = component.errors();
                for (auto error : errors) {
                    qCWarning(KirigamiPlatform) << error.toString();
                }

                qCWarning(KirigamiPlatform) << "Invalid Theme file, using default Basic theme.";
                m_themeDefinition = std::make_unique<BasicThemeDefinition>();
            }
        } else {
            qCDebug(KirigamiPlatform) << "No Theme.qml found, using default Basic theme";
            m_themeDefinition = std::make_unique<BasicThemeDefinition>();
        }
    }

    connect(m_themeDefinition.get(), &BasicThemeDefinition::changed, this, &BasicThemeInstance::onDefinitionChanged);

    return *m_themeDefinition;
}

void BasicThemeInstance::onDefinitionChanged()
{
    for (auto watcher : std::as_const(watchers)) {
        watcher->sync();
    }
}

Q_GLOBAL_STATIC(BasicThemeInstance, basicThemeInstance)

BasicTheme::BasicTheme(QObject *parent)
    : PlatformTheme(parent)
{
    basicThemeInstance()->watchers.append(this);

    sync();
}

BasicTheme::~BasicTheme()
{
    basicThemeInstance()->watchers.removeOne(this);
}

void BasicTheme::sync()
{
    PlatformThemeChangeTracker tracker{this};

    auto &definition = basicThemeInstance()->themeDefinition(qmlEngine(parent()));

    switch (colorSet()) {
    case BasicTheme::Button:
        setTextColor(tint(definition.buttonTextColor));
        setBackgroundColor(tint(definition.buttonBackgroundColor));
        setAlternateBackgroundColor(tint(definition.buttonAlternateBackgroundColor));
        setHoverColor(tint(definition.buttonHoverColor));
        setFocusColor(tint(definition.buttonFocusColor));
        break;
    case BasicTheme::View:
        setTextColor(tint(definition.viewTextColor));
        setBackgroundColor(tint(definition.viewBackgroundColor));
        setAlternateBackgroundColor(tint(definition.viewAlternateBackgroundColor));
        setHoverColor(tint(definition.viewHoverColor));
        setFocusColor(tint(definition.viewFocusColor));
        break;
    case BasicTheme::Selection:
        setTextColor(tint(definition.selectionTextColor));
        setBackgroundColor(tint(definition.selectionBackgroundColor));
        setAlternateBackgroundColor(tint(definition.selectionAlternateBackgroundColor));
        setHoverColor(tint(definition.selectionHoverColor));
        setFocusColor(tint(definition.selectionFocusColor));
        break;
    case BasicTheme::Tooltip:
        setTextColor(tint(definition.tooltipTextColor));
        setBackgroundColor(tint(definition.tooltipBackgroundColor));
        setAlternateBackgroundColor(tint(definition.tooltipAlternateBackgroundColor));
        setHoverColor(tint(definition.tooltipHoverColor));
        setFocusColor(tint(definition.tooltipFocusColor));
        break;
    case BasicTheme::Complementary:
        setTextColor(tint(definition.complementaryTextColor));
        setBackgroundColor(tint(definition.complementaryBackgroundColor));
        setAlternateBackgroundColor(tint(definition.complementaryAlternateBackgroundColor));
        setHoverColor(tint(definition.complementaryHoverColor));
        setFocusColor(tint(definition.complementaryFocusColor));
        break;
    case BasicTheme::Window:
    default:
        setTextColor(tint(definition.textColor));
        setBackgroundColor(tint(definition.backgroundColor));
        setAlternateBackgroundColor(tint(definition.alternateBackgroundColor));
        setHoverColor(tint(definition.hoverColor));
        setFocusColor(tint(definition.focusColor));
        break;
    }

    setDisabledTextColor(tint(definition.disabledTextColor));
    setHighlightColor(tint(definition.highlightColor));
    setHighlightedTextColor(tint(definition.highlightedTextColor));
    setActiveTextColor(tint(definition.activeTextColor));
    setActiveBackgroundColor(tint(definition.activeBackgroundColor));
    setLinkColor(tint(definition.linkColor));
    setLinkBackgroundColor(tint(definition.linkBackgroundColor));
    setVisitedLinkColor(tint(definition.visitedLinkColor));
    setVisitedLinkBackgroundColor(tint(definition.visitedLinkBackgroundColor));
    setNegativeTextColor(tint(definition.negativeTextColor));
    setNegativeBackgroundColor(tint(definition.negativeBackgroundColor));
    setNeutralTextColor(tint(definition.neutralTextColor));
    setNeutralBackgroundColor(tint(definition.neutralBackgroundColor));
    setPositiveTextColor(tint(definition.positiveTextColor));
    setPositiveBackgroundColor(tint(definition.positiveBackgroundColor));

    setDefaultFont(definition.defaultFont);
    setSmallFont(definition.smallFont);
}

bool BasicTheme::event(QEvent *event)
{
    if (event->type() == PlatformThemeEvents::DataChangedEvent::type) {
        sync();
    }

    if (event->type() == PlatformThemeEvents::ColorSetChangedEvent::type) {
        sync();
    }

    if (event->type() == PlatformThemeEvents::ColorGroupChangedEvent::type) {
        sync();
    }

    if (event->type() == PlatformThemeEvents::ColorChangedEvent::type) {
        basicThemeInstance()->themeDefinition(qmlEngine(parent())).syncToQml(this);
    }

    if (event->type() == PlatformThemeEvents::FontChangedEvent::type) {
        basicThemeInstance()->themeDefinition(qmlEngine(parent())).syncToQml(this);
    }

    return PlatformTheme::event(event);
}

QColor BasicTheme::tint(const QColor &color)
{
    if (QQuickItem *item = qobject_cast<QQuickItem *>(parent()); item && !item->isEnabled()) {
        return QColor::fromHsvF(color.hueF(), color.saturationF() * 0.5, color.valueF() * 0.8);
    }
    switch (colorGroup()) {
    case PlatformTheme::Inactive:
        return QColor::fromHsvF(color.hueF(), color.saturationF() * 0.5, color.valueF());
    case PlatformTheme::Disabled:
        return QColor::fromHsvF(color.hueF(), color.saturationF() * 0.5, color.valueF() * 0.8);
    default:
        return color;
    }
}

}
}

#include "moc_basictheme_p.cpp"
