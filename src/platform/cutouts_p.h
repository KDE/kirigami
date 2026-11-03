/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QQuickItem>

namespace Kirigami
{
namespace Platform
{

class CutoutsManager;
class CutoutsWayland;

class Cutouts : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT

public:
    Cutouts(QQuickItem *parent = nullptr);
    ~Cutouts();

    QList<QRectF> cutouts() const;

Q_SIGNALS:
    void cutoutsChanged();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;
    void itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value) override;

private:
    void connectAncestors(QQuickItem *item);

    CutoutsManager *m_cutoutsManager;
    CutoutsWayland *m_cutoutsWayland;
    QList<QQuickItem *> m_ancestors;
    QList<QRectF> m_cutouts;
};
}
}
