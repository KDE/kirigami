/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include "columnview.h"

#include <QPointer>
#include <QQuickItem>

class QPropertyAnimation;
class QQmlComponent;
namespace Kirigami
{
namespace Platform
{
class Units;
}
}

class QmlComponentsPool : public QObject
{
    Q_OBJECT

public:
    QmlComponentsPool(QQmlEngine *engine);
    ~QmlComponentsPool() override;

    QQmlComponent m_separatorComponent;
    Kirigami::Platform::Units *m_units = nullptr;

Q_SIGNALS:
    void gridUnitChanged();
    void longDurationChanged();
};

class ContentItem : public QQuickItem
{
    Q_OBJECT

public:
    ContentItem(ColumnView *parent = nullptr);
    ~ContentItem() override;

    void layoutItems();
    void layoutPinnedItems();
    qreal childWidth(QQuickItem *child);
    void updateVisibleItems();
    void forgetItem(QQuickItem *item);
    QQuickItem *ensureSeparator(QQuickItem *previousColumn, QQuickItem *column, QQuickItem *nextColumn);

    void setBoundedX(qreal x);
    void animateX(qreal x);
    void snapToItem();

    void connectHeader(QQuickItem *oldHeader, QQuickItem *newHeader);
    void connectFooter(QQuickItem *oldFooter, QQuickItem *newFooter);

    inline qreal viewportLeft() const;
    inline qreal viewportRight() const;

protected:
    void itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value) override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private Q_SLOTS:
    void syncItemsOrder();
    void updateRepeaterModel();

private:
    // Returns the item x position in the layout:
    // if is a normal item returns just the item x
    // if is pinned returns the position of the "hole" in the layout the item leaves
    qreal itemXinLayout(QQuickItem *item) const;

    ColumnView *m_view;
    QQuickItem *m_globalHeaderParent;
    QQuickItem *m_globalFooterParent;

    QPropertyAnimation *m_slideAnim;
    QList<QQuickItem *> m_items;
    QList<QQuickItem *> m_disappearingItems; // Items that are sliding away to be destroyed by a pop() animation
    QList<QQuickItem *> m_visibleItems;
    QPointer<QQuickItem> m_viewAnchorItem;
    // All the pinned items, mapped to all the positions they would have
    // if they were part of the normal layout
    QHash<QQuickItem *, qreal /*X pos*/> m_pinnedItems;
    QHash<QQuickItem *, QQuickItem *> m_separators;
    QHash<QObject *, QObject *> m_models;

    qreal m_leftPinnedSpace = 361;
    qreal m_rightPinnedSpace = 0;

    qreal m_columnWidth = 0;
    // This used just to figure out if the user intends to scroll left or right
    qreal m_lastDragDelta = 0;
    // This used for item dragging
    qreal m_touchDownX = 0;
    ColumnView::ColumnResizeMode m_columnResizeMode = ColumnView::FixedColumns;
    bool m_shouldAnimate = false;
    bool m_creationInProgress = true;
    friend class ColumnView;
};
