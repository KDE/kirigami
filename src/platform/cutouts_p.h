/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QDebug>
#include <QHash>
#include <QList>
#include <QObject>
#include <QRectF>

#include "helpers.h"
#include "qwayland-xx-cutouts-v1.h"
#include <QtWaylandClient/QWaylandClientExtension>
#include <QtWaylandClient/QWaylandClientExtensionTemplate>

class QWindow;

namespace Kirigami
{
namespace Platform
{

class CutoutsManager;
class CutoutsWayland;

class Cutouts : public QObject
{
    Q_OBJECT

public:
    ~Cutouts() override;

    static Cutouts *self();

    void registerWindow(QWindow *window);
    QList<QRectF> cutouts(QWindow *window);

Q_SIGNALS:
    void cutoutsChanged(QWindow *window, const QList<QRectF> &cutouts);

private:
    explicit Cutouts(QObject *parent = nullptr);
    void connectToNativeSurface(QWindow *window);
    void setupCutouts(QWindow *window);

    CutoutsManager *m_cutoutsManager = nullptr;
    QHash<QWindow *, CutoutsWayland *> m_cutoutsWayland;

    static Cutouts *s_cutouts;
};

}
}
