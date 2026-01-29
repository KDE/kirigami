/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMICONTROLSPLUGIN_H
#define KIRIGAMICONTROLSPLUGIN_H

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

class KirigamiControlsPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    KirigamiControlsPlugin(QObject *parent = nullptr);
    void registerTypes(const char *uri) override;
};

#endif
