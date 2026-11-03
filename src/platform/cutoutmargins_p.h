/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <QPointer>
#include <QQuickItem>
#include <qqmlregistration.h>

class QWindow;

namespace Kirigami
{
namespace Platform
{

class CutoutsManager;
class CutoutsWayland;

class CutoutsMargins : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(Kirigami::Platform::CutoutsMargins)
    QML_UNCREATABLE("Attached Property")

    Q_PROPERTY(qreal leftMargin READ leftMargin NOTIFY leftMarginChanged FINAL)
    Q_PROPERTY(qreal topMargin READ topMargin NOTIFY topMarginChanged FINAL)
    Q_PROPERTY(qreal rightMargin READ rightMargin NOTIFY rightMarginChanged FINAL)
    Q_PROPERTY(qreal bottomMargin READ bottomMargin NOTIFY bottomMarginChanged FINAL)

public:
    explicit CutoutsMargins(QObject *parent = nullptr);
    ~CutoutsMargins() override;

    qreal leftMargin() const;
    qreal topMargin() const;
    qreal rightMargin() const;
    qreal bottomMargin() const;

    static CutoutsMargins *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void leftMarginChanged();
    void topMarginChanged();
    void rightMarginChanged();
    void bottomMarginChanged();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    void connectAncestors(QQuickItem *item);
    void handleWindowChanged();
    void connectToNativeSurface();
    void setupCutouts();
    void refreshGeometries();

    QQuickItem *m_parentItem = nullptr;
    QMarginsF m_margins;

    CutoutsManager *m_cutoutsManager = nullptr;
    CutoutsWayland *m_cutoutsWayland = nullptr;
    QWindow *m_window = nullptr;
    QPointer<QObject> m_native;
    QList<QQuickItem *> m_ancestors;
    QList<QRectF> m_cutouts;
};

}
}
