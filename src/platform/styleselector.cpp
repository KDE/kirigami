/*
 * SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "styleselector.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QLibraryInfo>
#include <QQuickStyle>
#include <kirigamiplatform_logging.h>

using namespace Qt::StringLiterals;

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

    s_styleChain = {
        style,
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
        u"org.kde.desktop.plasma"_s,
        u"org.kde.desktop"_s,
#else
        u"Material"_s,
#endif
    };

    return s_styleChain;
}

QUrl StyleSelector::componentUrlForModule(const QString &module, const QString &fileName)
{
    // Try to find a styled version first.
    static const QStringList candidates = {
        // "New" style installation location, relative to specified module.
        u"{root}/{module}/styles/{style}/{file}"_s,
        // "Old" style installation location, relative to root Kirigami module.
        u"{root}/styles/{style}/{file}"_s,
    };

    const auto chain = styleChain();

    constexpr auto pathToUrl = [](const QString &path) {
        if (path.startsWith(u":/")) {
            return QUrl(u"qrc:///" + path.mid(2));
        } else {
            return QUrl::fromLocalFile(path);
        }
    };

    for (const auto &style : chain) {
        for (const auto &candidate : candidates) {
            auto path = candidate;
            path.replace(u"{root}"_s, installRoot());
            path.replace(u"{module}"_s, module);
            path.replace(u"{style}"_s, style);
            path.replace(u"{file}"_s, fileName);

            if (QFile::exists(path)) {
                qCDebug(KirigamiPlatform) << "Found" << path;
                return pathToUrl(path);
            }
        }
    }

    // If that failed, try to find an unstyled version.
    auto path = resolveFilePath(module + u'/' + fileName);
    if (QFile::exists(path)) {
        qCDebug(KirigamiPlatform) << "Found" << path;
        return pathToUrl(path);
    }

    qCDebug(KirigamiPlatform) << "Requested a non-existing component" << fileName;
    return QUrl();
}

QString StyleSelector::resolveFilePath(const QString &path)
{
    return installRoot() + u'/' + path;
}

QString StyleSelector::installRoot()
{
    // With static or android builds, always use QRC as installation root.
#if defined(KIRIGAMI_BUILD_TYPE_STATIC) || defined(Q_OS_ANDROID)
    static QString root = u":/qt/qml/org/kde/kirigami"_s;
#else
    static QString root;
#endif

    if (!root.isEmpty()) {
        return root;
    }

    // Try to find the QML path where Kirigami is installed.
    // This replicates some logic from QML which is not publicly available
    // except with a QQmlEngine instance, which we don't have access to here.
    // So instead, we need to find it manually.

    QStringList importPaths;
    importPaths.append(QCoreApplication::applicationDirPath());
    importPaths.append(qEnvironmentVariable("QML_IMPORT_PATH").split(QDir::listSeparator()));
    importPaths.append(qEnvironmentVariable("QML2_IMPORT_PATH").split(QDir::listSeparator()));
    importPaths.append(u":/qt/qml"_s);
    importPaths.append(QLibraryInfo::paths(QLibraryInfo::QmlImportsPath));

    for (auto path : importPaths) {
        if (!QFile::exists(path)) {
            continue;
        }

        QString kirigamiPath = path + u"/org/kde/kirigami";
        if (QFile::exists(kirigamiPath)) {
            qCDebug(KirigamiPlatform) << "Using" << kirigamiPath << "as installation root";
            root = kirigamiPath;
            break;
        }
    }

    return root;
}

#if KIRIGAMIPLATFORM_BUILD_DEPRECATED_SINCE(6, 24)
QUrl StyleSelector::componentUrl(const QString &fileName)
{
    return componentUrlForModule(QString{}, fileName);
}

void StyleSelector::setBaseUrl(const QUrl &baseUrl)
{
    Q_UNUSED(baseUrl);
}

QString StyleSelector::resolveFileUrl(const QString &path)
{
    return resolveFilePath(path);
}
#endif
}
}
