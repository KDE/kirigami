/*
 * SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "styleselector.h"

#include <QDir>
#include <QFile>
#include <QQuickStyle>
#include <kirigamiplatform_logging.h>

namespace Kirigami
{
namespace Platform
{

QString StyleSelector::style()
{
    if (qEnvironmentVariableIntValue("KIRIGAMI_FORCE_STYLE") == 1) {
        return QQuickStyle::name();
    } else {
        return styleChain().first();
    }
}

QStringList StyleSelector::styleChain()
{
    if (qEnvironmentVariableIntValue("KIRIGAMI_FORCE_STYLE") == 1) {
        return {QQuickStyle::name()};
    }

    if (!s_styleChain.isEmpty()) {
        return s_styleChain;
    }

    auto style = QQuickStyle::name();

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    // org.kde.desktop.plasma is a couple of files that fall back to desktop by purpose
    if (style.isEmpty() || style == QStringLiteral("org.kde.desktop.plasma")) {
        auto path = resolveFilePath(QStringLiteral("/styles/org.kde.desktop"));
        if (QFile::exists(path)) {
            s_styleChain.prepend(QStringLiteral("org.kde.desktop"));
        }
    }
#elif defined(Q_OS_ANDROID)
    s_styleChain.prepend(QStringLiteral("Material"));
#else // do we have an iOS specific style?
    s_styleChain.prepend(QStringLiteral("Material"));
#endif

    auto stylePath = resolveFilePath(QStringLiteral("/styles/") + style);
    if (!style.isEmpty() && QFile::exists(stylePath) && !s_styleChain.contains(style)) {
        s_styleChain.prepend(style);
        // if we have plasma deps installed, use them for extra integration
        auto plasmaPath = resolveFilePath(QStringLiteral("/styles/org.kde.desktop.plasma"));
        if (style == QStringLiteral("org.kde.desktop") && QFile::exists(plasmaPath)) {
            s_styleChain.prepend(QStringLiteral("org.kde.desktop.plasma"));
        }
    } else {
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
        s_styleChain.prepend(QStringLiteral("org.kde.desktop"));
#endif
    }

    return s_styleChain;
}

QUrl StyleSelector::componentUrl(const QString &fileName)
{
    const auto chain = styleChain();
    for (const QString &style : chain) {
        const QString candidate = QStringLiteral("styles/") + style + QLatin1Char('/') + fileName;
        if (QFile::exists(resolveFilePath(candidate))) {
            return QUrl(resolveFileUrl(candidate));
        }
    }

    if (!QFile::exists(resolveFilePath(fileName))) {
        qCWarning(KirigamiPlatform) << "Requested an unexisting component" << fileName;
    }
    return QUrl(resolveFileUrl(fileName));
}

void StyleSelector::setBaseUrl(const QUrl &baseUrl)
{
    s_baseUrl = baseUrl;
}

QString StyleSelector::resolveFilePath(const QString &path)
{
#if defined(KIRIGAMI_BUILD_TYPE_STATIC) || defined(Q_OS_ANDROID)
    if (path.endsWith(QStringLiteral(".qml")) && !path.endsWith(QStringLiteral("Theme.qml"))) {
        return QStringLiteral(":/qt/qml/org/kde/kirigami/controls/") + path;
    } else {
        return QStringLiteral(":/qt/qml/org/kde/kirigami/") + path;
    }
#else
    if (s_baseUrl.isValid()) {
        // HACK: this is a transition to support styles in their original place now that
        // controls are in their own import. This will be removed once styles are their own
        // import as well
        QString stylePath(path);
        stylePath.replace(QStringLiteral("styles/"), QStringLiteral("../styles/"));
        return s_baseUrl.toLocalFile() + QLatin1Char('/') + stylePath;
    } else {
        return QDir::currentPath() + QLatin1Char('/') + path;
    }
#endif
}

QString StyleSelector::resolveFileUrl(const QString &path)
{
#if defined(KIRIGAMI_BUILD_TYPE_STATIC) || defined(Q_OS_ANDROID)
    if (path.endsWith(QStringLiteral(".qml")) && !path.endsWith(QStringLiteral("Theme.qml"))) {
        return QStringLiteral("qrc:/qt/qml/org/kde/kirigami/controls/") + path;
    } else {
        return QStringLiteral("qrc:/qt/qml/org/kde/kirigami/") + path;
    }
#else
    // HACK: this is a transition to support styles in their original place now that
    // controls are in their own import. This will be removed once styles are their own
    // import as well
    QString stylePath(path);
    stylePath.replace(QStringLiteral("styles/"), QStringLiteral("../styles/"));
    return s_baseUrl.toString() + QLatin1Char('/') + stylePath;
#endif
}

}
}
