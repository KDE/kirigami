/*
 *  SPDX-FileCopyrightText: 2009 Alan Alpert <alan.alpert@nokia.com>
 *  SPDX-FileCopyrightText: 2010 Ménard Alexis <menard@kde.org>
 *  SPDX-FileCopyrightText: 2010 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMIFORMSPLUGIN_H
#define KIRIGAMIFORMSPLUGIN_H

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

class KirigamiFormsPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    KirigamiFormsPlugin(QObject *parent = nullptr);
    void registerTypes(const char *uri) override;
};

#endif
