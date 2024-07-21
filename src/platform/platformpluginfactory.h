/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMI_PLATFORMPLUGINFACTORY_H
#define KIRIGAMI_PLATFORMPLUGINFACTORY_H

#include <QObject>

#include "kirigamiplatform_export.h"

class QQmlEngine;

namespace Kirigami
{
namespace Platform
{
class PlatformTheme;
class Units;

/*!
 * \class Kirigami::Platform::PlatformPluginFactory
 * \inmodule KirigamiPlatform
 *
 * This class is reimpleented by plugins to provide different implementations
 * of PlatformTheme
 */
class KIRIGAMIPLATFORM_EXPORT PlatformPluginFactory : public QObject
{
    Q_OBJECT

public:
    explicit PlatformPluginFactory(QObject *parent = nullptr);
    ~PlatformPluginFactory() override;

    /*!
     * Creates an instance of PlatformTheme which can come out from
     * an implementation provided by a plugin
     *
     * If this returns nullptr the PlatformTheme will use a fallback
     * implementation that loads a theme definition from a QML file.
     *
     * @param parent the parent object of the created PlatformTheme
     */
    virtual PlatformTheme *createPlatformTheme(QObject *parent) = 0;

    /*!
     * Creates an instance of Units which can come from an implementation
     * provided by a plugin
     * @param parent the parent of the units object
     */
    virtual Units *createUnits(QObject *parent) = 0;

    /*!
     * finds the plugin providing units and platformtheme for the current style
     * The plugin pointer is cached, so only the first call is a potentially heavy operation
     * @param pluginName The name we want to search for, if empty the name of
     *           the current QtQuickControls style will be searched
     * @return pointer to the PlatformPluginFactory of the current style
     */
    static PlatformPluginFactory *findPlugin(const QString &pluginName = {});
};

}
}

QT_BEGIN_NAMESPACE
#define PlatformPluginFactory_iid "org.kde.kirigami.PlatformPluginFactory"
Q_DECLARE_INTERFACE(Kirigami::Platform::PlatformPluginFactory, PlatformPluginFactory_iid)
QT_END_NAMESPACE

#endif // PLATFORMPLUGINFACTORY_H
