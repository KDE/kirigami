/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "settings.h"

#include <QDebug>
#include <QFile>
#include <QGuiApplication>
#include <QIcon>
#include <QInputDevice>
#include <QMouseEvent>
#include <QSettings>
#include <QStandardPaths>
#include <QWindow>

#include <QtGui/private/qguiapplication_p.h>
#include <QtGui/qpa/qplatformmenu.h>
#include <QtGui/qpa/qplatformtheme.h>

#include "kirigamiplatform_version.h"
#include "smoothscrollwatcher.h"
#include "tabletmodewatcher.h"

namespace Kirigami
{
namespace Platform
{

class SettingsSingleton
{
public:
    Settings self;
};

Settings::Settings(QObject *parent)
    : QObject(parent)
    , m_hasTouchScreen(false)
    , m_hasTransientTouchInput(false)
{
    m_tabletModeAvailable = TabletModeWatcher::self()->isTabletModeAvailable();
    connect(TabletModeWatcher::self(), &TabletModeWatcher::tabletModeAvailableChanged, this, [this](bool tabletModeAvailable) {
        setTabletModeAvailable(tabletModeAvailable);
    });

    m_tabletMode = TabletModeWatcher::self()->isTabletMode();
    connect(TabletModeWatcher::self(), &TabletModeWatcher::tabletModeChanged, this, [this](bool tabletMode) {
        setTabletMode(tabletMode);
    });

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(UBUNTU_TOUCH)
    m_mobile = true;
    m_hasTouchScreen = true;
#else
    // Mostly for debug purposes and for platforms which are always mobile,
    // such as Plasma Mobile
    if (qEnvironmentVariableIsSet("QT_QUICK_CONTROLS_MOBILE")) {
        m_mobile = QByteArrayList{"1", "true"}.contains(qgetenv("QT_QUICK_CONTROLS_MOBILE"));
    } else {
        m_mobile = false;
    }

    const auto touchDevices = QInputDevice::devices();
    const auto touchDeviceType = QInputDevice::DeviceType::TouchScreen;
    for (const auto &device : touchDevices) {
        if (device->type() == touchDeviceType) {
            m_hasTouchScreen = true;
            break;
        }
    }
    if (m_hasTouchScreen) {
        connect(qApp, &QGuiApplication::focusWindowChanged, this, [this](QWindow *win) {
            if (win) {
                win->installEventFilter(this);
            }
        });
    }
#endif

    auto bar = QGuiApplicationPrivate::platformTheme()->createPlatformMenuBar();
    m_hasPlatformMenuBar = bar != nullptr;
    if (bar != nullptr) {
        bar->deleteLater();
    }

    const QString configPath = QStandardPaths::locate(QStandardPaths::ConfigLocation, QStringLiteral("kdeglobals"));
    if (QFile::exists(configPath)) {
        QSettings globals(configPath, QSettings::IniFormat);
        globals.beginGroup(QStringLiteral("KDE"));
        m_scrollLines = qMax(1, globals.value(QStringLiteral("WheelScrollLines"), 3).toInt());
        m_smoothScroll = globals.value(QStringLiteral("SmoothScroll"), true).toBool();
    } else {
        m_scrollLines = 3;
        m_smoothScroll = true;
    }

    connect(SmoothScrollWatcher::self(), &SmoothScrollWatcher::enabledChanged, this, [this](bool enabled) {
        m_smoothScroll = enabled;
        Q_EMIT smoothScrollChanged();
    });
}

Settings::~Settings()
{
}

bool Settings::eventFilter(QObject *watched, QEvent *event)
{
    Q_UNUSED(watched)
    switch (event->type()) {
    case QEvent::TouchBegin:
        setTransientTouchInput(true);
        break;
    case QEvent::MouseButtonPress:
    case QEvent::MouseMove: {
        QMouseEvent *me = static_cast<QMouseEvent *>(event);
        if (me->source() == Qt::MouseEventNotSynthesized) {
            setTransientTouchInput(false);
        }
        break;
    }
    case QEvent::Wheel:
        setTransientTouchInput(false);
    default:
        break;
    }

    return false;
}

void Settings::setTabletModeAvailable(bool mobileAvailable)
{
    if (mobileAvailable == m_tabletModeAvailable) {
        return;
    }

    m_tabletModeAvailable = mobileAvailable;
    Q_EMIT tabletModeAvailableChanged();
}

bool Settings::isTabletModeAvailable() const
{
    return m_tabletModeAvailable;
}

void Settings::setIsMobile(bool mobile)
{
    if (mobile == m_mobile) {
        return;
    }

    m_mobile = mobile;
    Q_EMIT isMobileChanged();
}

bool Settings::isMobile() const
{
    return m_mobile;
}

void Settings::setTabletMode(bool tablet)
{
    if (tablet == m_tabletMode) {
        return;
    }

    m_tabletMode = tablet;
    Q_EMIT tabletModeChanged();
}

bool Settings::tabletMode() const
{
    return m_tabletMode;
}

void Settings::setTransientTouchInput(bool touch)
{
    if (touch == m_hasTransientTouchInput) {
        return;
    }

    m_hasTransientTouchInput = touch;
    if (!m_tabletMode) {
        Q_EMIT hasTransientTouchInputChanged();
    }
}

bool Settings::hasTransientTouchInput() const
{
    return m_hasTransientTouchInput || m_tabletMode;
}

QString Settings::style() const
{
    return m_style;
}

void Settings::setStyle(const QString &style)
{
    m_style = style;
}

int Settings::mouseWheelScrollLines() const
{
    return m_scrollLines;
}

bool Settings::smoothScroll() const
{
    return m_smoothScroll;
}

QStringList Settings::information() const
{
    return {
#ifndef KIRIGAMI_BUILD_TYPE_STATIC
        tr("KDE Frameworks %1").arg(QStringLiteral(KIRIGAMIPLATFORM_VERSION_STRING)),
#endif
        tr("The %1 windowing system").arg(QGuiApplication::platformName()),
        tr("Qt %2 (built against %3)").arg(QString::fromLocal8Bit(qVersion()), QStringLiteral(QT_VERSION_STR))};
}

QVariant Settings::applicationWindowIcon() const
{
    const QIcon &windowIcon = qApp->windowIcon();
    if (windowIcon.isNull()) {
        return QVariant();
    }
    return windowIcon;
}

bool Settings::hasPlatformMenuBar() const
{
    return m_hasPlatformMenuBar;
}

}
}

#include "moc_settings.cpp"
