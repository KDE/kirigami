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
 * \inheaderfile Kirigami/Platform/PlatformPluginFactory
 * \inmodule KirigamiPlatform
 *
 * \brief This class is reimplemented by plugins to provide different implementations
 * of PlatformTheme.
 */
class KIRIGAMIPLATFORM_EXPORT PlatformPluginFactory : public QObject
{
    Q_OBJECT

public:
    explicit PlatformPluginFactory(QObject *parent = nullptr);
    ~PlatformPluginFactory() override;

    /*!
     * Creates an instance of PlatformTheme which can come out from
     * an implementation provided by a plugin.
     *
     * If this returns nullptr the PlatformTheme will use a fallback
     * implementation that loads a theme definition from a QML file.
     *
     * \a parent The parent object of the created PlatformTheme
     */
    virtual PlatformTheme *createPlatformTheme(QObject *parent) = 0;

    /*!
     * Creates an instance of Units which can come from an implementation
     * provided by a plugin
     *
     * \a parent The parent of the units object
     */
    virtual Units *createUnits(QObject *parent) = 0;

    /*!
     * Finds the plugin providing units and platformtheme for the current style
     * The plugin pointer is cached, so only the first call is a potentially heavy operation
     *
     * \a pluginName The name we want to search for, if empty the name of
     *           the current QtQuickControls style will be searched.
     *
     * Returns a pointer to the PlatformPluginFactory of the current style.
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
