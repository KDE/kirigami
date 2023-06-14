/*
 *  SPDX-FileCopyrightText: 2017 by Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "kirigamipluginfactory.h"

#include <QDebug>

#include <QDir>
#include <QQuickStyle>
#include <QPluginLoader>

#include "styleselector_p.h"
#include "units.h"

#include "loggingcategory.h"

namespace Kirigami {

KirigamiPluginFactory::KirigamiPluginFactory(QObject *parent)
    : QObject(parent)
{
}

KirigamiPluginFactory::~KirigamiPluginFactory() = default;

KirigamiPluginFactory *KirigamiPluginFactory::findPlugin(const QString &preferredName)
{
    static QHash<QString, KirigamiPluginFactory *> factories = QHash<QString, KirigamiPluginFactory *>();

    QString pluginName = preferredName.isEmpty() ? QQuickStyle::name() : preferredName;
    //check for the plugin only once: it's an heavy operation
    if (auto it = factories.constFind(pluginName); it != factories.constEnd()) {
        return it.value();
    }

    // Even plugins that aren't found are in the map, so we know we shouldn't check again withthis expensive operation
    factories[pluginName] = nullptr;

#ifdef KIRIGAMI_BUILD_TYPE_STATIC
    for (QObject *staticPlugin : QPluginLoader::staticInstances()) {
        KirigamiPluginFactory *factory = qobject_cast<KirigamiPluginFactory *>(staticPlugin);
        if (factory) {
            pluginFactory = factory;
        }
    }
#else
    const auto libraryPaths = QCoreApplication::libraryPaths();
    for (const QString &path : libraryPaths) {
#ifdef Q_OS_ANDROID
        QDir dir(path);
#else
        QDir dir(path + QStringLiteral("/kf6/kirigami"));
#endif
        const auto fileNames = dir.entryList(QDir::Files);

        for (const QString &fileName : fileNames) {

#ifdef Q_OS_ANDROID
            if (fileName.startsWith(QStringLiteral("libplugins_kf6_kirigami_")) && QLibrary::isLibrary(fileName)) {
#endif
                if (!pluginName.isEmpty() && fileName.contains(pluginName)) {
                    // TODO: env variable too?
                    QPluginLoader loader(dir.absoluteFilePath(fileName));
                    QObject *plugin = loader.instance();
                    // TODO: load actually a factory as plugin

                    qCDebug(KirigamiLog) << "Loading style plugin from" << dir.absoluteFilePath(fileName);

                    KirigamiPluginFactory *factory = qobject_cast<KirigamiPluginFactory *>(plugin);
                    if (factory) {
                        factories[pluginName] = factory;
                        break;
                    }
                }
#ifdef Q_OS_ANDROID
            }
#endif
        }

        // Ensure we only load the first plugin from the first plugin location.
        // If we do not break here, we may end up loading a different plugin
        // in place of the first one.
        if (auto it = factories.constFind(pluginName); it != factories.constEnd()) {
            break;
        }
    }
#endif

    return factories.value(pluginName);
}
}

#include "moc_kirigamipluginfactory.cpp"
