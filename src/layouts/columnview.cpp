/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "columnview.h"
#include "columnview_p.h"

#include "loggingcategory.h"
#include <QAbstractItemModel>
#include <QGuiApplication>
#include <QPropertyAnimation>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QStyleHints>
#include <algorithm>

#include "platform/units.h"

class QmlComponentsPoolSingleton
{
public:
    QmlComponentsPoolSingleton()
    {
    }
    static QmlComponentsPool *instance(QQmlEngine *engine);

private:
    QHash<QQmlEngine *, QmlComponentsPool *> m_instances;
};

Q_GLOBAL_STATIC(QmlComponentsPoolSingleton, privateQmlComponentsPoolSelf)

QmlComponentsPool *QmlComponentsPoolSingleton::instance(QQmlEngine *engine)
{
    Q_ASSERT(engine);
    auto componentPool = privateQmlComponentsPoolSelf->m_instances.value(engine);

    if (componentPool) {
        return componentPool;
    }

    componentPool = new QmlComponentsPool(engine);

    const auto removePool = [engine]() {
        // NB: do not derefence engine. it may be dangling already!
        if (privateQmlComponentsPoolSelf) {
            privateQmlComponentsPoolSelf->m_instances.remove(engine);
        }
    };
    QObject::connect(engine, &QObject::destroyed, engine, removePool);
    QObject::connect(componentPool, &QObject::destroyed, componentPool, removePool);

    privateQmlComponentsPoolSelf->m_instances[engine] = componentPool;
    return componentPool;
}

QmlComponentsPool::QmlComponentsPool(QQmlEngine *engine)
    : QObject(engine)
    , m_separatorComponent(engine)
{
    m_separatorComponent.loadFromModule("org.kde.kirigami.layouts.private", "ColumnViewSeparator");

    if (m_separatorComponent.isError()) {
        qCFatal(KirigamiLayoutsLog) << m_separatorComponent.errors();
    }

    m_units = engine->singletonInstance<Kirigami::Platform::Units *>("org.kde.kirigami.platform", "Units");
    Q_ASSERT(m_units);

    connect(m_units, &Kirigami::Platform::Units::gridUnitChanged, this, &QmlComponentsPool::gridUnitChanged);
    connect(m_units, &Kirigami::Platform::Units::longDurationChanged, this, &QmlComponentsPool::longDurationChanged);
}

QmlComponentsPool::~QmlComponentsPool()
{
}

/////////

ColumnViewAttached::ColumnViewAttached(QObject *parent)
    : QObject(parent)
{
}

ColumnViewAttached::~ColumnViewAttached()
{
}

void ColumnViewAttached::setIndex(int index)
{
    if (!m_customFillWidth && m_view) {
        const bool oldFillWidth = m_fillWidth;
        m_fillWidth = index == m_view->count() - 1;
        if (oldFillWidth != m_fillWidth) {
            Q_EMIT fillWidthChanged();
        }
    }

    if (index == m_index) {
        return;
    }

    m_index = index;
    Q_EMIT indexChanged();
}

int ColumnViewAttached::index() const
{
    return m_index;
}

void ColumnViewAttached::setFillWidth(bool fill)
{
    if (m_view) {
        disconnect(m_view.data(), &ColumnView::countChanged, this, nullptr);
    }
    m_customFillWidth = true;

    if (fill == m_fillWidth) {
        return;
    }

    m_fillWidth = fill;
    Q_EMIT fillWidthChanged();

    if (m_view) {
        m_view->polish();
    }
}

bool ColumnViewAttached::fillWidth() const
{
    return m_fillWidth;
}

qreal ColumnViewAttached::reservedSpace() const
{
    if (m_customReservedSpace) {
        return m_reservedSpace;
    } else if (m_view->columnResizeMode() == ColumnView::FixedColumns) {
        return m_view->columnWidth();
    } else {
        QQuickItem *prevItem = m_view->get(m_index - 1);
        QQuickItem *nextItem = m_view->get(m_index + 1);

        if (prevItem) {
            ColumnViewAttached *prevAttached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(prevItem, true));

            if (!prevAttached->fillWidth()) {
                return prevItem->width();
            }
        }
        if (nextItem) {
            ColumnViewAttached *prevAttached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(nextItem, true));

            if (!prevAttached->fillWidth()) {
                return nextItem->width();
            }
        }
    }
    return m_view->columnWidth();
}

void ColumnViewAttached::setReservedSpace(qreal space)
{
    if (m_view) {
        disconnect(m_view.data(), &ColumnView::columnWidthChanged, this, &ColumnViewAttached::reservedSpaceChanged);
    }
    m_customReservedSpace = true;

    if (qFuzzyCompare(space, m_reservedSpace)) {
        return;
    }

    m_reservedSpace = space;
    Q_EMIT reservedSpaceChanged();

    if (m_view) {
        m_view->polish();
    }
}

qreal ColumnViewAttached::minimumWidth() const
{
    return m_minimumWidth;
}

void ColumnViewAttached::setMinimumWidth(qreal width)
{
    if (qFuzzyCompare(width, m_minimumWidth)) {
        return;
    }

    m_minimumWidth = width;

    Q_EMIT minimumWidthChanged();

    if (m_view) {
        m_view->polish();
    }
}

qreal ColumnViewAttached::maximumWidth() const
{
    return m_maximumWidth;
}

void ColumnViewAttached::setMaximumWidth(qreal width)
{
    if (qFuzzyCompare(width, m_maximumWidth)) {
        return;
    }

    m_maximumWidth = width;

    Q_EMIT maximumWidthChanged();

    if (m_view) {
        m_view->polish();
    }
}

ColumnView *ColumnViewAttached::view()
{
    return m_view;
}

void ColumnViewAttached::setView(ColumnView *view)
{
    if (view == m_view) {
        return;
    }

    if (m_view) {
        disconnect(m_view.data(), nullptr, this, nullptr);
    }
    m_view = view;

    if (!m_customFillWidth && m_view) {
        m_fillWidth = m_index == m_view->count() - 1;
        connect(m_view.data(), &ColumnView::countChanged, this, [this]() {
            m_fillWidth = m_index == m_view->count() - 1;
            Q_EMIT fillWidthChanged();
        });
    }
    if (!m_customReservedSpace && m_view) {
        connect(m_view.data(), &ColumnView::columnWidthChanged, this, &ColumnViewAttached::reservedSpaceChanged);
    }

    Q_EMIT viewChanged();
}

QQuickItem *ColumnViewAttached::originalParent() const
{
    return m_originalParent;
}

void ColumnViewAttached::setOriginalParent(QQuickItem *parent)
{
    m_originalParent = parent;
}

bool ColumnViewAttached::shouldDeleteOnRemove() const
{
    return m_shouldDeleteOnRemove;
}

void ColumnViewAttached::setShouldDeleteOnRemove(bool del)
{
    m_shouldDeleteOnRemove = del;
}

bool ColumnViewAttached::preventStealing() const
{
    return m_preventStealing;
}

void ColumnViewAttached::setPreventStealing(bool prevent)
{
    if (prevent == m_preventStealing) {
        return;
    }

    m_preventStealing = prevent;
    Q_EMIT preventStealingChanged();
}

bool ColumnViewAttached::isPinned() const
{
    return m_pinned;
}

void ColumnViewAttached::setPinned(bool pinned)
{
    if (pinned == m_pinned) {
        return;
    }

    m_pinned = pinned;

    Q_EMIT pinnedChanged();

    if (m_view) {
        m_view->polish();
    }
}

bool ColumnViewAttached::inViewport() const
{
    return m_inViewport;
}

void ColumnViewAttached::setInViewport(bool inViewport)
{
    if (m_inViewport == inViewport) {
        return;
    }

    m_inViewport = inViewport;

    Q_EMIT inViewportChanged();
}

bool ColumnViewAttached::interactiveResizeEnabled() const
{
    return m_interactiveResizeEnabled;
}

void ColumnViewAttached::setInteractiveResizeEnabled(bool interactive)
{
    if (interactive == m_interactiveResizeEnabled) {
        return;
    }

    m_interactiveResizeEnabled = interactive;

    Q_EMIT interactiveResizeEnabledChanged();
}

bool ColumnViewAttached::interactiveResizing() const
{
    return m_interactiveResizing;
}

void ColumnViewAttached::setInteractiveResizing(bool interactive)
{
    if (interactive == m_interactiveResizing) {
        return;
    }

    m_interactiveResizing = interactive;

    Q_EMIT interactiveResizingChanged();
}

QQuickItem *ColumnViewAttached::globalHeader() const
{
    return m_globalHeader;
}

void ColumnViewAttached::setGlobalHeader(QQuickItem *header)
{
    if (header == m_globalHeader) {
        return;
    }

    QQuickItem *oldHeader = m_globalHeader;
    if (m_globalHeader) {
        disconnect(m_globalHeader, nullptr, this, nullptr);
    }

    m_globalHeader = header;

    connect(header, &QObject::destroyed, this, [this, header]() {
        globalHeaderChanged(header, nullptr);
    });

    Q_EMIT globalHeaderChanged(oldHeader, header);
}

QQuickItem *ColumnViewAttached::globalFooter() const
{
    return m_globalFooter;
}

void ColumnViewAttached::setGlobalFooter(QQuickItem *footer)
{
    if (footer == m_globalFooter) {
        return;
    }

    QQuickItem *oldFooter = m_globalFooter;
    if (m_globalFooter) {
        disconnect(m_globalFooter, nullptr, this, nullptr);
    }

    m_globalFooter = footer;

    connect(footer, &QObject::destroyed, this, [this, footer]() {
        globalFooterChanged(footer, nullptr);
    });

    Q_EMIT globalFooterChanged(oldFooter, footer);
}

/////////

ContentItem::ContentItem(ColumnView *parent)
    : QQuickItem(parent)
    , m_view(parent)
{
    m_globalHeaderParent = new QQuickItem(this);
    m_globalFooterParent = new QQuickItem(this);

    setFlags(flags() | ItemIsFocusScope);
    m_slideAnim = new QPropertyAnimation(this);
    m_slideAnim->setTargetObject(this);
    m_slideAnim->setPropertyName("x");
    // NOTE: the duration will be taken from kirigami units upon classBegin
    m_slideAnim->setDuration(0);
    m_slideAnim->setEasingCurve(QEasingCurve(QEasingCurve::OutExpo));
    connect(m_slideAnim, &QPropertyAnimation::finished, this, [this]() {
        if (!m_view->currentItem()) {
            m_view->setCurrentIndex(m_items.indexOf(m_viewAnchorItem));
        } else {
            QRectF mapped = m_view->currentItem()->mapRectToItem(m_view, QRectF(QPointF(0, 0), m_view->currentItem()->size()));
            if (!QRectF(QPointF(0, 0), m_view->size()).intersects(mapped)) {
                m_view->setCurrentIndex(m_items.indexOf(m_viewAnchorItem));
            }
        }
    });

    connect(this, &QQuickItem::xChanged, this, &ContentItem::layoutPinnedItems);
    m_creationInProgress = false;
}

ContentItem::~ContentItem()
{
}

void ContentItem::setBoundedX(qreal x)
{
    if (!parentItem()) {
        return;
    }
    m_slideAnim->stop();
    setX(qRound(qBound(qMin(0.0, -width() + parentItem()->width()), x, 0.0)));
}

void ContentItem::animateX(qreal newX)
{
    if (!parentItem()) {
        return;
    }

    const qreal to = qRound(qBound(qMin(0.0, -width() + parentItem()->width()), newX, 0.0));

    m_slideAnim->stop();
    m_slideAnim->setStartValue(x());
    m_slideAnim->setEndValue(to);
    m_slideAnim->start();
}

void ContentItem::snapToItem()
{
    QQuickItem *firstItem = childAt(viewportLeft(), height() / 2);
    if (!firstItem) {
        return;
    }
    QQuickItem *nextItem = childAt(firstItem->x() + firstItem->width() + 1, height() / 2);

    // need to make the last item visible?
    if (nextItem && //
        ((m_view->dragging() && m_lastDragDelta < 0) //
         || (!m_view->dragging() //
             && (width() - viewportRight()) < (viewportLeft() - firstItem->x())))) {
        m_viewAnchorItem = nextItem;
        animateX(-nextItem->x() + m_leftPinnedSpace);

        // The first one found?
    } else if ((m_view->dragging() && m_lastDragDelta >= 0) //
               || (!m_view->dragging() && (viewportLeft() <= (firstItem->x() + (firstItem->width() / 2)))) //
               || !nextItem) {
        m_viewAnchorItem = firstItem;
        animateX(-firstItem->x() + m_leftPinnedSpace);

        // the second?
    } else {
        m_viewAnchorItem = nextItem;
        animateX(-nextItem->x() + m_leftPinnedSpace);
    }
}

qreal ContentItem::viewportLeft() const
{
    return -x() + m_leftPinnedSpace;
}

qreal ContentItem::viewportRight() const
{
    return -x() + m_view->width() - m_rightPinnedSpace;
}

qreal ContentItem::childWidth(QQuickItem *child)
{
    if (!parentItem()) {
        return 0.0;
    }

    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(child, true));

    if (m_columnResizeMode == ColumnView::SingleColumn) {
        return qRound(parentItem()->width());

    } else if (attached->fillWidth()) {
        if (m_view->count() == 1) {
            // single column
            return qRound(parentItem()->width());
        }

        return qRound(qBound(m_columnWidth, (parentItem()->width() - attached->reservedSpace()), std::max(m_columnWidth, parentItem()->width())));

    } else if (m_columnResizeMode == ColumnView::FixedColumns) {
        return qRound(qMin(parentItem()->width(), m_columnWidth));

        // DynamicColumns
    } else {
        // TODO:look for Layout size hints
        qreal width = child->implicitWidth();

        if (width < 1.0) {
            width = m_columnWidth;
        }

        if (attached->minimumWidth() >= 0 && attached->maximumWidth() >= 0) {
            width = std::clamp(width, attached->minimumWidth(), attached->maximumWidth());
        } else if (attached->minimumWidth() >= 0) {
            width = std::max(width, attached->minimumWidth());
        } else if (attached->maximumWidth() >= 0) {
            width = std::min(width, attached->maximumWidth());
        }

        return qRound(qMin(m_view->width(), width));
    }
}

void ContentItem::layoutItems()
{
    setY(m_view->topPadding());
    setHeight(m_view->height() - m_view->topPadding() - m_view->bottomPadding());

    qreal implicitWidth = 0;
    qreal implicitHeight = 0;
    qreal partialWidth = 0;
    int i = 0;
    m_leftPinnedSpace = 0;
    m_rightPinnedSpace = 0;

    bool reverse = qApp->layoutDirection() == Qt::RightToLeft;
    auto it = !reverse ? m_items.begin() : m_items.end();
    int increment = reverse ? -1 : +1;
    auto lastPos = reverse ? m_items.begin() : m_items.end();

    QQuickItem *previousChild = nullptr;

    for (; it != lastPos; it += increment) {
        // for (QQuickItem *child : std::as_const(m_items)) {
        QQuickItem *child = reverse ? *(it - 1) : *it;
        QQuickItem *nextChild = nullptr;
        if (reverse) {
            if (it != lastPos) {
                nextChild = *it;
            }
        } else {
            if ((it + 1) != lastPos) {
                nextChild = *(it + 1);
            }
        }

        ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(child, true));
        if (child == m_globalHeaderParent || child == m_globalFooterParent) {
            continue;
        }

        if (child->isVisible()) {
            if (attached->isPinned() && m_view->columnResizeMode() != ColumnView::SingleColumn) {
                QQuickItem *sep = nullptr;
                int sepWidth = 0;
                if (m_view->separatorVisible()) {
                    sep = ensureSeparator(previousChild, child, nextChild);
                    sepWidth = (sep ? sep->width() : 0);
                }
                const qreal width = childWidth(child);
                const qreal widthDiff = std::max(0.0, m_view->width() - child->width()); // it's possible for the view width to be smaller than the child width
                const qreal pageX = std::clamp(partialWidth, -x(), -x() + widthDiff);
                qreal headerHeight = .0;
                qreal footerHeight = .0;
                if (QQuickItem *header = attached->globalHeader()) {
                    headerHeight = header->isVisible() ? header->height() : .0;
                    header->setWidth(width + sepWidth);
                    header->setPosition(QPointF(pageX, .0));
                    header->setZ(2);
                }
                if (QQuickItem *footer = attached->globalFooter()) {
                    footerHeight = footer->isVisible() ? footer->height() : .0;
                    footer->setWidth(width + sepWidth);
                    footer->setPosition(QPointF(pageX, height() - footerHeight));
                    footer->setZ(2);
                }

                child->setSize(QSizeF(width + sepWidth, height() - headerHeight - footerHeight));
                child->setPosition(QPointF(pageX, headerHeight));
                child->setZ(1);

                if (partialWidth <= -x()) {
                    m_leftPinnedSpace = qMax(m_leftPinnedSpace, width);
                } else if (partialWidth > -x() + m_view->width() - child->width() + sepWidth) {
                    m_rightPinnedSpace = qMax(m_rightPinnedSpace, child->width());
                }

                partialWidth += width;

            } else {
                const qreal width = childWidth(child);
                qreal headerHeight = .0;
                qreal footerHeight = .0;
                if (m_view->separatorVisible()) {
                    ensureSeparator(previousChild, child, nextChild);
                }
                if (QQuickItem *header = attached->globalHeader(); header && qmlEngine(header)) {
                    headerHeight = header->isVisible() ? header->height() : .0;
                    header->setWidth(width);
                    header->setPosition(QPointF(partialWidth, .0));
                    header->setZ(1);
                    auto it = m_separators.find(header);
                    if (it != m_separators.end()) {
                        it.value()->deleteLater();
                        m_separators.erase(it);
                    }
                }
                if (QQuickItem *footer = attached->globalFooter(); footer && qmlEngine(footer)) {
                    footerHeight = footer->isVisible() ? footer->height() : .0;
                    footer->setWidth(width);
                    footer->setPosition(QPointF(partialWidth, height() - footerHeight));
                    footer->setZ(1);
                    // TODO: remove
                    auto it = m_separators.find(footer);
                    if (it != m_separators.end()) {
                        it.value()->deleteLater();
                        m_separators.erase(it);
                    }
                }

                child->setSize(QSizeF(width, height() - headerHeight - footerHeight));

                child->setPosition(QPointF(partialWidth, headerHeight));
                child->setZ(0);

                partialWidth += child->width();
            }
        }

        if (reverse) {
            attached->setIndex(m_items.count() - (++i));
        } else {
            attached->setIndex(i++);
        }

        implicitWidth += child->implicitWidth();

        implicitHeight = qMax(implicitHeight, child->implicitHeight());

        previousChild = child;
    }

    setWidth(partialWidth);

    setImplicitWidth(implicitWidth);
    setImplicitHeight(implicitHeight);

    m_view->setImplicitWidth(implicitWidth);
    m_view->setImplicitHeight(implicitHeight + m_view->topPadding() + m_view->bottomPadding());

    const qreal newContentX = m_viewAnchorItem ? -m_viewAnchorItem->x() : 0.0;
    if (m_shouldAnimate) {
        animateX(newContentX);
    } else {
        setBoundedX(newContentX);
    }

    updateVisibleItems();
}

void ContentItem::layoutPinnedItems()
{
    if (m_view->columnResizeMode() == ColumnView::SingleColumn) {
        return;
    }
    return;
    qreal partialWidth = 0;
    m_leftPinnedSpace = 0;
    m_rightPinnedSpace = 0;

    QQuickItem *previousChild = nullptr;

    for (auto it = m_items.constBegin(); it != m_items.constEnd(); it++) {
        // for (QQuickItem *child : std::as_const(m_items)) {
        QQuickItem *child = *it;
        QQuickItem *nextChild = *(it + 1);
        //  for (QQuickItem *child : std::as_const(m_items)) {
        ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(child, true));

        if (child->isVisible()) {
            if (attached->isPinned()) {
                QQuickItem *sep = nullptr;
                int sepWidth = 0;
                if (m_view->separatorVisible()) {
                    sep = ensureSeparator(previousChild, child, nextChild);
                    sepWidth = (sep ? sep->width() : 0);
                }

                const qreal pageX = qMin(qMax(-x(), partialWidth), -x() + m_view->width() - child->width() + sepWidth);
                qreal headerHeight = .0;
                qreal footerHeight = .0;
                if (QQuickItem *header = attached->globalHeader()) {
                    headerHeight = header->isVisible() ? header->height() : .0;
                    header->setPosition(QPointF(pageX, .0));
                }
                if (QQuickItem *footer = attached->globalFooter()) {
                    footerHeight = footer->isVisible() ? footer->height() : .0;
                    footer->setPosition(QPointF(pageX, height() - footerHeight));
                }
                child->setPosition(QPointF(pageX, headerHeight));

                if (partialWidth <= -x()) {
                    m_leftPinnedSpace = qMax(m_leftPinnedSpace, child->width() - sepWidth);
                } else if (partialWidth > -x() + m_view->width() - child->width() + sepWidth) {
                    m_rightPinnedSpace = qMax(m_rightPinnedSpace, child->width());
                }
            }

            partialWidth += child->width();
        }
    }
}

void ContentItem::updateVisibleItems()
{
    QList<QQuickItem *> newItems;

    for (auto *item : std::as_const(m_items)) {
        ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, true));

        if (item->isVisible() && item->x() + x() < m_view->width() && item->x() + item->width() + x() > 0) {
            newItems << item;
            connect(item, &QObject::destroyed, this, [this, item] {
                m_visibleItems.removeAll(item);
            });
            attached->setInViewport(true);
            item->setEnabled(true);
            if (attached->globalHeader()) {
                attached->globalHeader()->setEnabled(true);
            }
            if (attached->globalFooter()) {
                attached->globalFooter()->setEnabled(true);
            }
        } else {
            attached->setInViewport(false);
            item->setEnabled(false);
            if (attached->globalHeader()) {
                attached->globalHeader()->setEnabled(false);
            }
            if (attached->globalFooter()) {
                attached->globalFooter()->setEnabled(false);
            }
        }
    }

    for (auto *item : std::as_const(m_visibleItems)) {
        disconnect(item, &QObject::destroyed, this, nullptr);
    }

    const QQuickItem *oldLeadingVisibleItem = m_view->leadingVisibleItem();
    const QQuickItem *oldTrailingVisibleItem = m_view->trailingVisibleItem();

    if (newItems != m_visibleItems) {
        m_visibleItems = newItems;
        Q_EMIT m_view->visibleItemsChanged();
        if (!m_visibleItems.isEmpty() && m_visibleItems.first() != oldLeadingVisibleItem) {
            Q_EMIT m_view->leadingVisibleItemChanged();
        }
        if (!m_visibleItems.isEmpty() && m_visibleItems.last() != oldTrailingVisibleItem) {
            Q_EMIT m_view->trailingVisibleItemChanged();
        }
    }
}

void ContentItem::forgetItem(QQuickItem *item)
{
    if (!m_items.contains(item)) {
        return;
    }

    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, true));
    attached->setView(nullptr);
    attached->setIndex(-1);

    disconnect(attached, nullptr, this, nullptr);
    disconnect(item, nullptr, this, nullptr);
    disconnect(item, nullptr, m_view, nullptr);

    QQuickItem *separatorItem = m_separators.take(item);
    if (separatorItem) {
        separatorItem->deleteLater();
    }

    if (QQuickItem *header = attached->globalHeader()) {
        header->setVisible(false);
        header->setParentItem(item);
        separatorItem = m_separators.take(header);
        if (separatorItem) {
            separatorItem->deleteLater();
        }
    }
    if (QQuickItem *footer = attached->globalFooter()) {
        footer->setVisible(false);
        footer->setParentItem(item);
        separatorItem = m_separators.take(footer);
        if (separatorItem) {
            separatorItem->deleteLater();
        }
    }

    const int index = m_items.indexOf(item);
    m_items.removeAll(item);
    // We are connected not only to destroyed but also to lambdas
    disconnect(item, nullptr, this, nullptr);
    updateVisibleItems();
    m_shouldAnimate = true;
    m_view->polish();

    if (index <= m_view->currentIndex()) {
        m_view->setCurrentIndex(m_items.isEmpty() ? 0 : qBound(0, index - 1, m_items.count() - 1));
    }
    Q_EMIT m_view->countChanged();
}

QQuickItem *ContentItem::ensureSeparator(QQuickItem *previousColumn, QQuickItem *column, QQuickItem *nextColumn)
{
    QQuickItem *separatorItem = m_separators.value(column);

    if (!separatorItem) {
        separatorItem = qobject_cast<QQuickItem *>(
            QmlComponentsPoolSingleton::instance(qmlEngine(column))->m_separatorComponent.beginCreate(QQmlEngine::contextForObject(column)));
        if (separatorItem) {
            separatorItem->setParent(this);
            separatorItem->setParentItem(column);
            separatorItem->setZ(9999);
            separatorItem->setProperty("column", QVariant::fromValue(column));
            QmlComponentsPoolSingleton::instance(qmlEngine(column))->m_separatorComponent.completeCreate();
            m_separators[column] = separatorItem;
        }
    }

    if (separatorItem) {
        separatorItem->setProperty("previousColumn", QVariant::fromValue(previousColumn));
        separatorItem->setProperty("nextColumn", QVariant::fromValue(nextColumn));
    }

    return separatorItem;
}

void ContentItem::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value)
{
    if (m_creationInProgress) {
        QQuickItem::itemChange(change, value);
        return;
    }
    switch (change) {
    case QQuickItem::ItemChildAddedChange: {
        ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(value.item, true));
        attached->setView(m_view);

        // connect(attached, &ColumnViewAttached::fillWidthChanged, m_view, &ColumnView::polish);
        connect(attached, &ColumnViewAttached::fillWidthChanged, this, [this] {
            m_view->polish();
        });
        connect(attached, &ColumnViewAttached::reservedSpaceChanged, m_view, &ColumnView::polish);

        value.item->setVisible(true);

        if (!m_items.contains(value.item)) {
            connect(value.item, &QQuickItem::widthChanged, m_view, &ColumnView::polish);
            QQuickItem *item = value.item;
            m_items << item;
            connect(item, &QObject::destroyed, this, [this, item]() {
                m_view->removeItem(item);
            });
        }

        m_shouldAnimate = true;
        m_view->polish();
        Q_EMIT m_view->countChanged();
        break;
    }
    case QQuickItem::ItemChildRemovedChange: {
        forgetItem(value.item);
        break;
    }
    case QQuickItem::ItemVisibleHasChanged:
        updateVisibleItems();
        if (value.boolValue) {
            m_view->polish();
        }
        break;
    default:
        break;
    }
    QQuickItem::itemChange(change, value);
}

void ContentItem::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    updateVisibleItems();
    QQuickItem::geometryChange(newGeometry, oldGeometry);
}

void ContentItem::syncItemsOrder()
{
    if (m_items == childItems()) {
        return;
    }

    m_items = childItems();
    // NOTE: polish() here sometimes gets indefinitely delayed and items changing order isn't seen
    layoutItems();
}

void ContentItem::updateRepeaterModel()
{
    if (!sender()) {
        return;
    }

    QObject *modelObj = sender()->property("model").value<QObject *>();

    if (!modelObj) {
        m_models.remove(sender());
        return;
    }

    if (m_models[sender()]) {
        disconnect(m_models[sender()], nullptr, this, nullptr);
    }

    m_models[sender()] = modelObj;

    QAbstractItemModel *qaim = qobject_cast<QAbstractItemModel *>(modelObj);

    if (qaim) {
        connect(qaim, &QAbstractItemModel::rowsMoved, this, &ContentItem::syncItemsOrder);

    } else {
        connect(modelObj, SIGNAL(childrenChanged()), this, SLOT(syncItemsOrder()));
    }
}

void ContentItem::connectHeader(QQuickItem *oldHeader, QQuickItem *newHeader)
{
    if (oldHeader) {
        disconnect(oldHeader, nullptr, this, nullptr);
        oldHeader->setParentItem(nullptr);
    }
    if (newHeader) {
        connect(newHeader, &QQuickItem::heightChanged, this, &ContentItem::layoutItems);
        connect(newHeader, &QQuickItem::visibleChanged, this, &ContentItem::layoutItems);
        newHeader->setParentItem(m_globalHeaderParent);
    }
}

void ContentItem::connectFooter(QQuickItem *oldFooter, QQuickItem *newFooter)
{
    if (oldFooter) {
        disconnect(oldFooter, nullptr, this, nullptr);
        oldFooter->setParentItem(nullptr);
    }
    if (newFooter) {
        connect(newFooter, &QQuickItem::heightChanged, this, &ContentItem::layoutItems);
        connect(newFooter, &QQuickItem::visibleChanged, this, &ContentItem::layoutItems);
        newFooter->setParentItem(m_globalFooterParent);
    }
}

ColumnView::ColumnView(QQuickItem *parent)
    : QQuickItem(parent)
    , m_contentItem(nullptr)
{
    // NOTE: this is to *not* trigger itemChange
    m_contentItem = new ContentItem(this);
    // Prevent interactions outside of ColumnView bounds, and let it act as a viewport.
    setClip(true);
    setAcceptedMouseButtons(Qt::BackButton | Qt::ForwardButton);
    setAcceptHoverEvents(false);
    setAcceptTouchEvents(true);
    setFiltersChildMouseEvents(true);

    connect(m_contentItem->m_slideAnim, &QPropertyAnimation::finished, this, [this]() {
        m_moving = false;
        Q_EMIT movingChanged();
    });
    connect(m_contentItem, &ContentItem::widthChanged, this, &ColumnView::contentWidthChanged);
    connect(m_contentItem, &ContentItem::xChanged, this, &ColumnView::contentXChanged);

    connect(this, &ColumnView::activeFocusChanged, this, [this]() {
        if (hasActiveFocus() && m_currentItem) {
            m_currentItem->forceActiveFocus();
        }
    });
    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(this, true));
    attached->setView(this);
    attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(m_contentItem, true));
    attached->setView(this);
}

ColumnView::~ColumnView()
{
}

ColumnView::ColumnResizeMode ColumnView::columnResizeMode() const
{
    return m_contentItem->m_columnResizeMode;
}

void ColumnView::setColumnResizeMode(ColumnResizeMode mode)
{
    if (m_contentItem->m_columnResizeMode == mode) {
        return;
    }

    m_contentItem->m_columnResizeMode = mode;
    if (mode == SingleColumn && m_currentItem) {
        m_contentItem->m_viewAnchorItem = m_currentItem;
    }
    m_contentItem->m_shouldAnimate = false;
    polish();
    Q_EMIT columnResizeModeChanged();
}

qreal ColumnView::columnWidth() const
{
    return m_contentItem->m_columnWidth;
}

void ColumnView::setColumnWidth(qreal width)
{
    // Always forget the internal binding when the user sets anything, even the same value
    disconnect(QmlComponentsPoolSingleton::instance(qmlEngine(this)), &QmlComponentsPool::gridUnitChanged, this, nullptr);

    if (m_contentItem->m_columnWidth == width) {
        return;
    }

    m_contentItem->m_columnWidth = width;
    m_contentItem->m_shouldAnimate = false;
    polish();
    Q_EMIT columnWidthChanged();
}

int ColumnView::currentIndex() const
{
    return m_currentIndex;
}

void ColumnView::setCurrentIndex(int index)
{
    if (m_currentIndex == index || index < -1 || index >= m_contentItem->m_items.count()) {
        return;
    }

    m_currentIndex = index;

    if (index == -1) {
        m_currentItem.clear();

    } else {
        m_currentItem = m_contentItem->m_items[index];
        Q_ASSERT(m_currentItem);
        m_currentItem->forceActiveFocus();

        // If the current item is not on view, scroll
        QRectF mappedCurrent = m_currentItem->mapRectToItem(this, QRectF(QPointF(0, 0), m_currentItem->size()));

        if (m_contentItem->m_slideAnim->state() == QAbstractAnimation::Running) {
            mappedCurrent.moveLeft(mappedCurrent.left() + m_contentItem->x() + m_contentItem->m_slideAnim->endValue().toInt());
        }

        // m_contentItem->m_slideAnim->stop();

        QRectF contentsRect(m_contentItem->m_leftPinnedSpace, //
                            0,
                            width() - m_contentItem->m_rightPinnedSpace - m_contentItem->m_leftPinnedSpace,
                            height());

        if (!m_dragging) {
            if (!contentsRect.contains(mappedCurrent)) {
                m_contentItem->m_viewAnchorItem = m_currentItem;
                if (qApp->layoutDirection() == Qt::RightToLeft) {
                    m_contentItem->animateX(-m_currentItem->x() - m_currentItem->width() + width());
                } else {
                    m_contentItem->animateX(-m_currentItem->x() + m_contentItem->m_leftPinnedSpace);
                }
            } else {
                m_contentItem->snapToItem();
                m_dragging = false;
            }
        }
    }

    Q_EMIT currentIndexChanged();
    Q_EMIT currentItemChanged();
}

QQuickItem *ColumnView::currentItem()
{
    return m_currentItem;
}

QList<QQuickItem *> ColumnView::visibleItems() const
{
    return m_contentItem->m_visibleItems;
}

QQuickItem *ColumnView::leadingVisibleItem() const
{
    if (m_contentItem->m_visibleItems.isEmpty()) {
        return nullptr;
    }

    return m_contentItem->m_visibleItems.first();
}

QQuickItem *ColumnView::trailingVisibleItem() const
{
    if (m_contentItem->m_visibleItems.isEmpty()) {
        return nullptr;
    }

    return qobject_cast<QQuickItem *>(m_contentItem->m_visibleItems.last());
}

int ColumnView::count() const
{
    return m_contentItem->m_items.count();
}

qreal ColumnView::topPadding() const
{
    return m_topPadding;
}

void ColumnView::setTopPadding(qreal padding)
{
    if (padding == m_topPadding) {
        return;
    }

    m_topPadding = padding;
    polish();
    Q_EMIT topPaddingChanged();
}

qreal ColumnView::bottomPadding() const
{
    return m_bottomPadding;
}

void ColumnView::setBottomPadding(qreal padding)
{
    if (padding == m_bottomPadding) {
        return;
    }

    m_bottomPadding = padding;
    polish();
    Q_EMIT bottomPaddingChanged();
}

QQuickItem *ColumnView::contentItem() const
{
    return m_contentItem;
}

int ColumnView::scrollDuration() const
{
    return m_contentItem->m_slideAnim->duration();
}

void ColumnView::setScrollDuration(int duration)
{
    disconnect(QmlComponentsPoolSingleton::instance(qmlEngine(this)), &QmlComponentsPool::longDurationChanged, this, nullptr);

    if (m_contentItem->m_slideAnim->duration() == duration) {
        return;
    }

    m_contentItem->m_slideAnim->setDuration(duration);
    Q_EMIT scrollDurationChanged();
}

bool ColumnView::separatorVisible() const
{
    return m_separatorVisible;
}

void ColumnView::setSeparatorVisible(bool visible)
{
    if (visible == m_separatorVisible) {
        return;
    }

    m_separatorVisible = visible;

    Q_EMIT separatorVisibleChanged();
}

bool ColumnView::dragging() const
{
    return m_dragging;
}

bool ColumnView::moving() const
{
    return m_moving;
}

qreal ColumnView::contentWidth() const
{
    return m_contentItem->width();
}

qreal ColumnView::contentX() const
{
    return -m_contentItem->x();
}

void ColumnView::setContentX(qreal x) const
{
    m_contentItem->setX(qRound(-x));
}

bool ColumnView::interactive() const
{
    return m_interactive;
}

void ColumnView::setInteractive(bool interactive)
{
    if (m_interactive == interactive) {
        return;
    }

    m_interactive = interactive;

    if (!m_interactive) {
        m_contentItem->snapToItem();

        if (m_dragging) {
            m_dragging = false;
            Q_EMIT draggingChanged();
        }

        setKeepMouseGrab(false);
    }

    Q_EMIT interactiveChanged();
}

bool ColumnView::acceptsMouse() const
{
    return m_acceptsMouse;
}

void ColumnView::setAcceptsMouse(bool accepts)
{
    if (m_acceptsMouse == accepts) {
        return;
    }

    m_acceptsMouse = accepts;

    Q_EMIT acceptsMouseChanged();
}

void ColumnView::addItem(QQuickItem *item)
{
    insertItem(m_contentItem->m_items.length(), item);
}

void ColumnView::insertItem(int pos, QQuickItem *item)
{
    if (!item || m_contentItem->m_items.contains(item)) {
        return;
    }

    m_contentItem->m_items.insert(qBound(0, pos, m_contentItem->m_items.length()), item);

    connect(item, &QObject::destroyed, m_contentItem, [this, item]() {
        removeItem(item);
    });
    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, true));
    attached->setOriginalParent(item->parentItem());
    attached->setShouldDeleteOnRemove(item->parentItem() == nullptr && QQmlEngine::objectOwnership(item) == QQmlEngine::JavaScriptOwnership);
    item->setParentItem(m_contentItem);
    connect(item, &QQuickItem::implicitWidthChanged, this, &ColumnView::polish);

    item->forceActiveFocus();

    if (attached->globalHeader()) {
        m_contentItem->connectHeader(nullptr, attached->globalHeader());
    }
    if (attached->globalFooter()) {
        m_contentItem->connectFooter(nullptr, attached->globalFooter());
    }
    connect(attached, &ColumnViewAttached::globalHeaderChanged, m_contentItem, &ContentItem::connectHeader);
    connect(attached, &ColumnViewAttached::globalFooterChanged, m_contentItem, &ContentItem::connectFooter);

    // Animate shift to new item.
    m_contentItem->m_shouldAnimate = true;
    m_contentItem->layoutItems();
    Q_EMIT contentChildrenChanged();

    // In order to keep the same current item we need to increase the current index if displaced
    // NOTE: just updating m_currentIndex does *not* update currentItem (which is what we need atm) while setCurrentIndex will update also currentItem
    if (m_currentIndex >= pos) {
        ++m_currentIndex;
        Q_EMIT currentIndexChanged();
    }

    Q_EMIT itemInserted(pos, item);
}

void ColumnView::replaceItem(int pos, QQuickItem *item)
{
    if (pos < 0 || pos >= m_contentItem->m_items.length()) {
        qCWarning(KirigamiLayoutsLog) << "Position" << pos << "passed to ColumnView::replaceItem is out of range.";
        return;
    }

    if (!item) {
        qCWarning(KirigamiLayoutsLog) << "Null item passed to ColumnView::replaceItem.";
        return;
    }

    QQuickItem *oldItem = m_contentItem->m_items[pos];

    // In order to keep the same current item we need to increase the current index if displaced
    if (m_currentIndex >= pos) {
        setCurrentIndex(m_currentIndex - 1);
    }

    m_contentItem->forgetItem(oldItem);
    oldItem->setVisible(false);

    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(oldItem, false));

    if (attached && attached->shouldDeleteOnRemove()) {
        oldItem->deleteLater();
    } else {
        oldItem->setParentItem(attached ? attached->originalParent() : nullptr);
    }

    Q_EMIT itemRemoved(oldItem);

    if (!m_contentItem->m_items.contains(item)) {
        m_contentItem->m_items.insert(qBound(0, pos, m_contentItem->m_items.length()), item);

        connect(item, &QObject::destroyed, m_contentItem, [this, item]() {
            removeItem(item);
        });
        ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, true));
        attached->setOriginalParent(item->parentItem());
        attached->setShouldDeleteOnRemove(item->parentItem() == nullptr && QQmlEngine::objectOwnership(item) == QQmlEngine::JavaScriptOwnership);
        item->setParentItem(m_contentItem);
        connect(item, &QQuickItem::implicitWidthChanged, this, &ColumnView::polish);

        if (attached->globalHeader()) {
            m_contentItem->connectHeader(nullptr, attached->globalHeader());
        }
        if (attached->globalFooter()) {
            m_contentItem->connectFooter(nullptr, attached->globalFooter());
        }
        connect(attached, &ColumnViewAttached::globalHeaderChanged, m_contentItem, &ContentItem::connectHeader);
        connect(attached, &ColumnViewAttached::globalFooterChanged, m_contentItem, &ContentItem::connectFooter);

        if (m_currentIndex >= pos) {
            ++m_currentIndex;
            Q_EMIT currentIndexChanged();
        }

        Q_EMIT itemInserted(pos, item);
    }

    // Disable animation so replacement happens immediately.
    m_contentItem->m_shouldAnimate = false;
    m_contentItem->layoutItems();
    Q_EMIT contentChildrenChanged();
}

void ColumnView::moveItem(int from, int to)
{
    if (m_contentItem->m_items.isEmpty() //
        || from < 0 || from >= m_contentItem->m_items.length() //
        || to < 0 || to >= m_contentItem->m_items.length()) {
        return;
    }

    m_contentItem->m_items.move(from, to);
    m_contentItem->m_shouldAnimate = true;

    if (from == m_currentIndex) {
        m_currentIndex = to;
        Q_EMIT currentIndexChanged();
    } else if (from < m_currentIndex && to > m_currentIndex) {
        --m_currentIndex;
        Q_EMIT currentIndexChanged();
    } else if (from > m_currentIndex && to <= m_currentIndex) {
        ++m_currentIndex;
        Q_EMIT currentIndexChanged();
    }

    polish();
}

QQuickItem *ColumnView::removeItem(QQuickItem *item)
{
    if (m_contentItem->m_items.isEmpty() || !m_contentItem->m_items.contains(item)) {
        return nullptr;
    }

    const int index = m_contentItem->m_items.indexOf(item);

    // In order to keep the same current item we need to increase the current index if displaced
    if (m_currentIndex >= index) {
        setCurrentIndex(m_currentIndex - 1);
    }

    m_contentItem->forgetItem(item);
    item->setVisible(false);

    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, false));

    if (attached && attached->shouldDeleteOnRemove()) {
        item->deleteLater();
    } else {
        item->setParentItem(attached ? attached->originalParent() : nullptr);
    }

    Q_EMIT contentChildrenChanged();
    Q_EMIT itemRemoved(item);

    return item;
}

QQuickItem *ColumnView::removeItem(const int index)
{
    if (m_contentItem->m_items.isEmpty() || index < 0 || index >= count()) {
        return nullptr;
    } else {
        return removeItem(m_contentItem->m_items[index]);
    }
}

QQuickItem *ColumnView::removeItem(const QVariant &item)
{
    if (item.canConvert<QQuickItem *>()) {
        return removeItem(item.value<QQuickItem *>());
    } else if (item.canConvert<int>()) {
        return removeItem(item.toInt());
    } else {
        return nullptr;
    }
}

QQuickItem *ColumnView::get(int index)
{
    if (index < 0 || index > m_contentItem->m_items.count() - 1) {
        return nullptr;
    }

    return m_contentItem->m_items.value(index);
}

QQuickItem *ColumnView::pop(const QVariant &item)
{
    if (item.canConvert<QQuickItem *>()) {
        return pop(item.value<QQuickItem *>());
    } else if (item.canConvert<int>()) {
        return pop(item.toInt());
    } else if (item.isNull()) {
        return pop();
    }
    return nullptr;
}
QQuickItem *ColumnView::pop(QQuickItem *item)
{
    QQuickItem *removed = nullptr;

    while (!m_contentItem->m_items.isEmpty() && m_contentItem->m_items.last() != item) {
        removed = removeItem(m_contentItem->m_items.last());
    }
    return removed;
}

QQuickItem *ColumnView::pop(const int index)
{
    if (index >= 0 && index < count() - 1) {
        return pop(m_contentItem->m_items.at(index));
    } else if (index == -1) {
        return pop(nullptr);
    }
    return nullptr;
}

QQuickItem *ColumnView::pop()
{
    if (count() > 0) {
        return removeItem(count() - 1);
    }
    return nullptr;
}

void ColumnView::clear()
{
    // Don't do an iterator on a list that gets progressively destroyed, treat it as a stack
    while (!m_contentItem->m_items.isEmpty()) {
        QQuickItem *item = m_contentItem->m_items.first();
        removeItem(item);
    }

    m_contentItem->m_items.clear();
    Q_EMIT contentChildrenChanged();
}

bool ColumnView::containsItem(QQuickItem *item)
{
    return m_contentItem->m_items.contains(item);
}

QQuickItem *ColumnView::itemAt(qreal x, qreal y)
{
    return m_contentItem->childAt(x, y);
}

ColumnViewAttached *ColumnView::qmlAttachedProperties(QObject *object)
{
    return new ColumnViewAttached(object);
}

void ColumnView::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    m_contentItem->setY(m_topPadding);
    m_contentItem->setHeight(newGeometry.height() - m_topPadding - m_bottomPadding);
    m_contentItem->m_shouldAnimate = false;
    polish();

    m_contentItem->updateVisibleItems();
    QQuickItem::geometryChange(newGeometry, oldGeometry);
}

bool ColumnView::childMouseEventFilter(QQuickItem *item, QEvent *event)
{
    if (!m_interactive || item == m_contentItem) {
        return QQuickItem::childMouseEventFilter(item, event);
    }

    switch (event->type()) {
    case QEvent::TouchBegin: {
        QTouchEvent *te = static_cast<QTouchEvent *>(event);

        if (te->pointCount() != 1) {
            return false;
        }

        m_verticalScrollIntercepted = false;
        // On press, we set the current index of the view to the root item
        QQuickItem *candidateItem = item;
        while (candidateItem->parentItem() && candidateItem->parentItem() != m_contentItem) {
            candidateItem = candidateItem->parentItem();
        }
        if (int idx = m_contentItem->m_items.indexOf(candidateItem); idx >= 0 && candidateItem->parentItem() == m_contentItem) {
            setCurrentIndex(idx);
        }

        // m_acceptsMouse is a noop now

        m_contentItem->m_slideAnim->stop();
        if (item->property("preventStealing").toBool()) {
            m_contentItem->snapToItem();
            return false;
        }

        te->setAccepted(false);

        break;
    }
    case QEvent::TouchUpdate: {
        QTouchEvent *te = static_cast<QTouchEvent *>(event);

        if (te->pointCount() != 1) {
            return false;
        }

        const QPointF pressPos = mapFromItem(item, te->points().first().pressPosition());
        const QPointF lastPos = mapFromItem(item, te->points().first().lastPosition());
        const QPointF pos = mapFromItem(item, te->points().first().position());

        m_verticalScrollIntercepted = m_verticalScrollIntercepted || std::abs(pos.y() - pressPos.y()) > qApp->styleHints()->startDragDistance() * 3;

        if (m_verticalScrollIntercepted) {
            m_contentItem->snapToItem();
            m_dragging = false;
            return false;
        }

        QQuickItem *candidateItem = item;
        while (candidateItem->parentItem() && candidateItem->parentItem() != m_contentItem) {
            candidateItem = candidateItem->parentItem();
        }
        if (candidateItem->parentItem() == m_contentItem) {
            ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(candidateItem, true));
            if (attached->preventStealing()) {
                return false;
            }
        }

        {
            ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(candidateItem, true));

            ScrollIntentionEvent scrollIntentionEvent;
            scrollIntentionEvent.delta = pos - lastPos;

            Q_EMIT attached->scrollIntention(&scrollIntentionEvent);

            if (scrollIntentionEvent.accepted) {
                m_verticalScrollIntercepted = true;
                event->setAccepted(true);
            }
        }

        if (item->keepTouchGrab() || item->property("preventStealing").toBool()) {
            m_contentItem->snapToItem();
            m_dragging = false;
            return false;
        }

        const bool wasDragging = m_dragging;
        // If a drag happened, start to steal all events, use startDragDistance * 2 to give time to widgets to take the mouse grab by themselves
        m_dragging = !m_verticalScrollIntercepted && std::abs(pos.x() - pressPos.x()) > qApp->styleHints()->startDragDistance() * 3;

        if (m_dragging != wasDragging) {
            m_moving = true;
            Q_EMIT movingChanged();
            Q_EMIT draggingChanged();
        }

        m_contentItem->m_lastDragDelta = pos.x() - lastPos.x();

        if (m_dragging) {
            m_contentItem->setBoundedX(m_contentItem->x() + m_contentItem->m_lastDragDelta);
        }

        te->setAccepted(m_dragging);

        return m_dragging;
    }
    case QEvent::TouchEnd:
    case QEvent::TouchCancel: {
        QTouchEvent *te = static_cast<QTouchEvent *>(event);
        if (item->property("preventStealing").toBool()) {
            return false;
        }

        m_verticalScrollIntercepted = false;
        // if a drag happened, don't pass the event
        const bool block = m_dragging;

        m_contentItem->snapToItem();

        if (m_dragging) {
            m_contentItem->m_lastDragDelta = 0;
            m_dragging = false;
            Q_EMIT draggingChanged();
        }

        event->accept();

        te->setAccepted(block);
        return block;
    }
    case QEvent::MouseButtonRelease: {
        QMouseEvent *me = static_cast<QMouseEvent *>(event);
        if (me->button() == Qt::BackButton && m_currentIndex > 0) {
            setCurrentIndex(m_currentIndex - 1);
            me->accept();
            return true;
        } else if (me->button() == Qt::ForwardButton) {
            setCurrentIndex(m_currentIndex + 1);
            me->accept();
            return true;
        }
        break;
    }
    default:
        break;
    }

    return QQuickItem::childMouseEventFilter(item, event);
}

bool ColumnView::event(QEvent *event)
{
    if (!m_interactive) {
        return QQuickItem::event(event);
    }
    switch (event->type()) {
    case QEvent::TouchBegin: {
        QTouchEvent *te = static_cast<QTouchEvent *>(event);

        if (te->pointCount() != 1) {
            m_contentItem->snapToItem();
            m_dragging = false;
        }
        break;
    }
    case QEvent::TouchUpdate: {
        QTouchEvent *te = static_cast<QTouchEvent *>(event);

        if (te->pointCount() != 1) {
            m_contentItem->snapToItem();
            m_dragging = false;
            break;
        }

        m_dragging = true;

        const QEventPoint point = te->points().first();

        m_contentItem->m_lastDragDelta = point.position().x() - point.lastPosition().x();
        m_contentItem->setBoundedX(m_contentItem->x() + m_contentItem->m_lastDragDelta);
        break;
    }
    case QEvent::TouchEnd:
    case QEvent::TouchCancel:
        m_contentItem->snapToItem();
        m_dragging = false;
        break;
    default:
        break;
    }
    return QQuickItem::event(event);
}

void ColumnView::mousePressEvent(QMouseEvent *event)
{
    if (!m_acceptsMouse && event->source() == Qt::MouseEventNotSynthesized) {
        event->setAccepted(false);
        return;
    }

    if (event->button() == Qt::BackButton || event->button() == Qt::ForwardButton) {
        event->accept();
    }
}

void ColumnView::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() == Qt::BackButton && m_currentIndex > 0) {
        setCurrentIndex(m_currentIndex - 1);
        event->accept();
        return;
    } else if (event->button() == Qt::ForwardButton) {
        setCurrentIndex(m_currentIndex + 1);
        event->accept();
        return;
    }
}

void ColumnView::classBegin()
{
    auto syncColumnWidth = [this]() {
        m_contentItem->m_columnWidth = privateQmlComponentsPoolSelf->instance(qmlEngine(this))->m_units->gridUnit() * 20;
        Q_EMIT columnWidthChanged();
    };

    connect(QmlComponentsPoolSingleton::instance(qmlEngine(this)), &QmlComponentsPool::gridUnitChanged, this, syncColumnWidth);
    syncColumnWidth();

    auto syncDuration = [this]() {
        m_contentItem->m_slideAnim->setDuration(QmlComponentsPoolSingleton::instance(qmlEngine(this))->m_units->veryLongDuration());
        Q_EMIT scrollDurationChanged();
    };

    connect(QmlComponentsPoolSingleton::instance(qmlEngine(this)), &QmlComponentsPool::longDurationChanged, this, syncDuration);
    syncDuration();

    QQuickItem::classBegin();
}

void ColumnView::componentComplete()
{
    m_complete = true;
    QQuickItem::componentComplete();
}

void ColumnView::updatePolish()
{
    m_contentItem->layoutItems();
}

void ColumnView::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value)
{
    switch (change) {
    case QQuickItem::ItemChildAddedChange:
        if (m_contentItem && value.item != m_contentItem && !value.item->inherits("QQuickRepeater")) {
            addItem(value.item);
        }
        break;
    default:
        break;
    }
    QQuickItem::itemChange(change, value);
}

void ColumnView::contentChildren_append(QQmlListProperty<QQuickItem> *prop, QQuickItem *item)
{
    // This can only be called from QML
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return;
    }

    view->m_contentItem->m_items.append(item);
    connect(item, &QObject::destroyed, view->m_contentItem, [view, item]() {
        view->removeItem(item);
    });

    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, true));
    attached->setOriginalParent(item->parentItem());
    attached->setShouldDeleteOnRemove(item->parentItem() == nullptr && QQmlEngine::objectOwnership(item) == QQmlEngine::JavaScriptOwnership);

    item->setParentItem(view->m_contentItem);
}

qsizetype ColumnView::contentChildren_count(QQmlListProperty<QQuickItem> *prop)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return 0;
    }

    return view->m_contentItem->m_items.count();
}

QQuickItem *ColumnView::contentChildren_at(QQmlListProperty<QQuickItem> *prop, qsizetype index)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return nullptr;
    }

    if (index < 0 || index >= view->m_contentItem->m_items.count()) {
        return nullptr;
    }
    return view->m_contentItem->m_items.value(index);
}

void ColumnView::contentChildren_clear(QQmlListProperty<QQuickItem> *prop)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return;
    }

    return view->m_contentItem->m_items.clear();
}

QQmlListProperty<QQuickItem> ColumnView::contentChildren()
{
    return QQmlListProperty<QQuickItem>(this, //
                                        nullptr,
                                        contentChildren_append,
                                        contentChildren_count,
                                        contentChildren_at,
                                        contentChildren_clear);
}

void ColumnView::contentData_append(QQmlListProperty<QObject> *prop, QObject *object)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return;
    }

    view->m_contentData.append(object);
    QQuickItem *item = qobject_cast<QQuickItem *>(object);
    // exclude repeaters from layout
    if (item && item->inherits("QQuickRepeater")) {
        item->setParentItem(view);

        connect(item, SIGNAL(modelChanged()), view->m_contentItem, SLOT(updateRepeaterModel()));

    } else if (item) {
        view->m_contentItem->m_items.append(item);
        connect(item, &QObject::destroyed, view->m_contentItem, [view, item]() {
            view->removeItem(item);
        });

        ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, true));
        attached->setOriginalParent(item->parentItem());
        attached->setShouldDeleteOnRemove(view->m_complete && !item->parentItem() && QQmlEngine::objectOwnership(item) == QQmlEngine::JavaScriptOwnership);

        item->setParentItem(view->m_contentItem);

    } else {
        object->setParent(view);
    }
}

qsizetype ColumnView::contentData_count(QQmlListProperty<QObject> *prop)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return 0;
    }

    return view->m_contentData.count();
}

QObject *ColumnView::contentData_at(QQmlListProperty<QObject> *prop, qsizetype index)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return nullptr;
    }

    if (index < 0 || index >= view->m_contentData.count()) {
        return nullptr;
    }
    return view->m_contentData.value(index);
}

void ColumnView::contentData_clear(QQmlListProperty<QObject> *prop)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return;
    }

    return view->m_contentData.clear();
}

QQmlListProperty<QObject> ColumnView::contentData()
{
    return QQmlListProperty<QObject>(this, //
                                     nullptr,
                                     contentData_append,
                                     contentData_count,
                                     contentData_at,
                                     contentData_clear);
}

#include "moc_columnview.cpp"
#include "moc_columnview_p.cpp"
