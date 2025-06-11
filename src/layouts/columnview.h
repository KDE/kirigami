/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <QPointer>
#include <QQuickItem>
#include <QVariant>

class ContentItem;
class ColumnView;

class ScrollIntentionEvent : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QPointF delta MEMBER delta CONSTANT FINAL)
    Q_PROPERTY(bool accepted MEMBER accepted FINAL)
public:
    ScrollIntentionEvent()
    {
    }
    ~ScrollIntentionEvent() override
    {
    }

    QPointF delta;
    bool accepted = false;
};

class ColumnViewAttached : public QObject
{
    Q_OBJECT

    /*!
     * \qmlattachedproperty int ColumnView::index
     *
     * The index position of the column in the view, starting from 0
     */
    Q_PROPERTY(int index READ index WRITE setIndex NOTIFY indexChanged FINAL)

    /*!
     * \qmlattachedproperty bool ColumnView::fillWidth
     *
     * If true, the column will expand to take the whole viewport space minus reservedSpace
     */
    Q_PROPERTY(bool fillWidth READ fillWidth WRITE setFillWidth NOTIFY fillWidthChanged FINAL)

    /*!
     * \qmlattachedproperty real ColumnView::reservedSpace
     *
     * When a column is fillWidth, it will keep reservedSpace amount of pixels from going to fill the full viewport width
     */
    Q_PROPERTY(qreal reservedSpace READ reservedSpace WRITE setReservedSpace NOTIFY reservedSpaceChanged FINAL)

    /*!
     * \qmlattachedproperty real ColumnView::minimumWidth
     *
     * When a column is interactiveResizeEnabled, when resizing manually it will bound
     * the column size between minimumWidth and maximumWidth
     *
     * \since 6.16
     */
    Q_PROPERTY(qreal minimumWidth READ minimumWidth WRITE setMinimumWidth NOTIFY minimumWidthChanged FINAL)

    /*!
     * \qmlattachedproperty real ColumnView::maximumWidth
     *
     * When a column is interactiveResizeEnabled, when resizing manually it will bound
     * the column size between minimumWidth and maximumWidth
     *
     * \since 6.16
     */
    Q_PROPERTY(qreal maximumWidth READ maximumWidth WRITE setMaximumWidth NOTIFY maximumWidthChanged FINAL)

    /*!
     * \qmlattachedproperty bool ColumnView::preventStealing
     *
     * Like the same property of MouseArea, when this is true, the column view won't
     * try to manage events by itself when filtering from a child, not
     * disturbing user interaction
     */
    Q_PROPERTY(bool preventStealing READ preventStealing WRITE setPreventStealing NOTIFY preventStealingChanged FINAL)

    /*!
     * \qmlattachedproperty bool ColumnView::pinned
     *
     * If true the page will never go out of view, but will stay either
     * at the right or left side of the ColumnView
     */
    Q_PROPERTY(bool pinned READ isPinned WRITE setPinned NOTIFY pinnedChanged FINAL)

    /*!
     * \qmlattachedproperty ColumnView ColumnView::view
     * \readonly
     *
     * The view this column belongs to
     */
    Q_PROPERTY(ColumnView *view READ view NOTIFY viewChanged FINAL)

    /*!
     * \qmlattachedproperty bool ColumnView::inViewport
     * \readonly
     *
     * True if this column is at least partly visible in the ColumnView's viewport.
     * \since 5.77
     */
    Q_PROPERTY(bool inViewport READ inViewport NOTIFY inViewportChanged FINAL)

    /*!
     * \qmlattachedproperty bool ColumnView::interactiveResizeEnabled
     *
     * True if this column supports interactive resize with mouse.
     *
     * If the sizes should be saved and restored on application startup,
     * it is the application responsibility to implement this, for instance exposing
     * and object with properties for the desired column widths which
     * reads and writes to the config. at the main Component.onCompleted of the
     * ApplicationWindow root Item it will apply the preferred sizes of the desired pages.
     *
     * The property will be written at interactiveResizingChanged signal handler.
     *
     * \since 6.16
     */
    Q_PROPERTY(bool interactiveResizeEnabled READ interactiveResizeEnabled WRITE setInteractiveResizeEnabled NOTIFY interactiveResizeEnabledChanged)

    /*!
     * \qmlattachedproperty bool ColumnView::interactiveResizing
     *
     * True when the user is actively resizing a column with the mouse.
     * If the application wants to write the column sizes to config,
     * it can sync to some global object property at interactiveResizingChanged:
     * \qml
     *      Kirigami.ColumnView.onInteractiveResizingChanged: {
     *          if (!Kirigami.ColumnView.interactiveResizing) {
     *              myAppObject.leftColumnWidth = page.implicitWidth;
     *          }
     *      }
     * \endqml
     * \since 6.16
     */
    Q_PROPERTY(bool interactiveResizing READ interactiveResizing WRITE setInteractiveResizing NOTIFY interactiveResizingChanged)

    /*!
     * \qmlattachedproperty Item ColumnView::globalHeader
     */
    Q_PROPERTY(QQuickItem *globalHeader READ globalHeader WRITE setGlobalHeader NOTIFY globalHeaderChanged FINAL)

    /*!
     * \qmlattachedproperty Item ColumnView::globalFooter
     */
    Q_PROPERTY(QQuickItem *globalFooter READ globalFooter WRITE setGlobalFooter NOTIFY globalFooterChanged FINAL)

public:
    ColumnViewAttached(QObject *parent = nullptr);
    ~ColumnViewAttached() override;

    void setIndex(int index);
    int index() const;

    void setFillWidth(bool fill);
    bool fillWidth() const;

    qreal reservedSpace() const;
    void setReservedSpace(qreal space);

    qreal minimumWidth() const;
    void setMinimumWidth(qreal space);

    qreal maximumWidth() const;
    void setMaximumWidth(qreal space);

    ColumnView *view();
    void setView(ColumnView *view);

    // Private API, not for QML use
    QQuickItem *originalParent() const;
    void setOriginalParent(QQuickItem *parent);

    bool shouldDeleteOnRemove() const;
    void setShouldDeleteOnRemove(bool del);

    bool preventStealing() const;
    void setPreventStealing(bool prevent);

    bool isPinned() const;
    void setPinned(bool pinned);

    bool inViewport() const;
    void setInViewport(bool inViewport);

    bool interactiveResizeEnabled() const;
    void setInteractiveResizeEnabled(bool interactive);

    bool interactiveResizing() const;
    void setInteractiveResizing(bool interactive);

    QQuickItem *globalHeader() const;
    void setGlobalHeader(QQuickItem *header);

    QQuickItem *globalFooter() const;
    void setGlobalFooter(QQuickItem *footer);

Q_SIGNALS:
    void indexChanged();
    void fillWidthChanged();
    void reservedSpaceChanged();
    void minimumWidthChanged();
    void maximumWidthChanged();
    void viewChanged();
    void preventStealingChanged();
    void pinnedChanged();
    void scrollIntention(ScrollIntentionEvent *event);
    void inViewportChanged();
    void interactiveResizeEnabledChanged();
    void interactiveResizingChanged();
    void globalHeaderChanged(QQuickItem *oldHeader, QQuickItem *newHeader);
    void globalFooterChanged(QQuickItem *oldFooter, QQuickItem *newFooter);

private:
    int m_index = -1;
    bool m_fillWidth = false;
    qreal m_reservedSpace = 0;
    qreal m_minimumWidth = -1;
    qreal m_maximumWidth = -1;
    QPointer<ColumnView> m_view;
    QPointer<QQuickItem> m_originalParent;
    bool m_customFillWidth = false;
    bool m_customReservedSpace = false;
    bool m_shouldDeleteOnRemove = true;
    bool m_preventStealing = false;
    bool m_pinned = false;
    bool m_inViewport = false;
    bool m_interactiveResizeEnabled = false;
    bool m_interactiveResizing = false;
    QPointer<QQuickItem> m_globalHeader;
    QPointer<QQuickItem> m_globalFooter;
};

/*!
 * \qmltype ColumnView
 * \inqmlmodule org.kde.kirigami.layouts
 *
 * \brief A container that lays out items horizontally in a row.
 *
 * When not all items fit in the ColumnView, it will behave like a Flickable and will be a scrollable view which shows only a determined number of columns.
 *
 * The columns can either all have the same fixed size (recommended),
 * size themselves with implicitWidth, or automatically expand to take all the available width: by default the last column will always be the expanding one.
 *
 * Items inside the ColumnView can access info of the view and set layouting hints via the ColumnView attached property.
 *
 * This is the base for the implementation of PageRow.
 * \since 2.7
 */
class ColumnView : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(ColumnViewAttached)

    /*!
     * \qmlproperty enumeration ColumnView::columnResizeMode
     *
     * The strategy to follow while automatically resizing the columns
     *
     * \qmlenumeratorsfrom ColumnView::ColumnResizeMode
     *
     * The default is FixedColumns.
     */
    Q_PROPERTY(ColumnResizeMode columnResizeMode READ columnResizeMode WRITE setColumnResizeMode NOTIFY columnResizeModeChanged FINAL)

    /*!
     * \qmlproperty real ColumnView::columnWidth
     *
     * The width of all columns when columnResizeMode is FixedColumns
     */
    Q_PROPERTY(qreal columnWidth READ columnWidth WRITE setColumnWidth NOTIFY columnWidthChanged FINAL)

    /*!
     * \qmlproperty int ColumnView::count
     * \readonly
     *
     * How many columns this view contains
     */
    Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

    /*!
     * \qmlproperty int ColumnView::currentIndex
     *
     * The position of the currently active column. The current column will also have keyboard focus
     */
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged FINAL)

    /*!
     * \qmlproperty Item ColumnView::currentItem
     * \readonly
     *
     * The currently active column. The current column will also have keyboard focus
     */
    Q_PROPERTY(QQuickItem *currentItem READ currentItem NOTIFY currentItemChanged FINAL)

    /*!
     * \qmlproperty Item ColumnView::contentItem
     * \readonly
     *
     * The main content item of this view: it's the parent of the column items
     */
    Q_PROPERTY(QQuickItem *contentItem READ contentItem CONSTANT FINAL)

    /*!
     * \qmlproperty real ColumnView::contentX
     *
     * The value of the horizontal scroll of the view, in pixels
     */
    Q_PROPERTY(qreal contentX READ contentX WRITE setContentX NOTIFY contentXChanged FINAL)

    /*!
     * \qmlproperty real ColumnView::contentWidth
     * \readonly
     *
     * The compound width of all columns in the view
     */
    Q_PROPERTY(qreal contentWidth READ contentWidth NOTIFY contentWidthChanged FINAL)

    /*!
     * \qmlproperty real ColumnView::topPadding
     *
     * The padding this will have at the top
     */
    Q_PROPERTY(qreal topPadding READ topPadding WRITE setTopPadding NOTIFY topPaddingChanged FINAL)

    /*!
     * \qmlproperty real ColumnView::bottomPadding
     *
     * The padding this will have at the bottom
     */
    Q_PROPERTY(qreal bottomPadding READ bottomPadding WRITE setBottomPadding NOTIFY bottomPaddingChanged FINAL)

    /*!
     * \qmlproperty int ColumnView::scrollDuration
     *
     * The duration for scrolling animations
     */
    Q_PROPERTY(int scrollDuration READ scrollDuration WRITE setScrollDuration NOTIFY scrollDurationChanged FINAL)

    /*!
     * \qmlproperty bool ColumnView::separatorVisible
     *
     * True if columns should be visually separated by a separator line
     */
    Q_PROPERTY(bool separatorVisible READ separatorVisible WRITE setSeparatorVisible NOTIFY separatorVisibleChanged FINAL)

    /*!
     * \qmlproperty list<QtObject> ColumnView::visibleItems
     * \readonly
     *
     * The list of all visible column items that are at least partially in the viewport at any given moment
     */
    Q_PROPERTY(QList<QQuickItem *> visibleItems READ visibleItems NOTIFY visibleItemsChanged FINAL)

    /*!
     * \qmlproperty Item ColumnView::leadingVisibleItem
     * \readonly
     *
     * The first of visibleItems provided from convenience
     */
    Q_PROPERTY(QQuickItem *leadingVisibleItem READ leadingVisibleItem NOTIFY leadingVisibleItemChanged FINAL)

    /*!
     * \qmlproperty Item ColumnView::trailingVisibleItem
     * \readonly
     *
     * The last of visibleItems provided from convenience
     */
    Q_PROPERTY(QQuickItem *trailingVisibleItem READ trailingVisibleItem NOTIFY trailingVisibleItemChanged FINAL)

    // Properties to make it similar to Flickable
    /*!
     * \qmlproperty bool ColumnView::dragging
     * \readonly
     *
     * True when the user is dragging around with touch gestures the view contents
     */
    Q_PROPERTY(bool dragging READ dragging NOTIFY draggingChanged FINAL)

    /*!
     * \qmlproperty bool ColumnView::moving
     * \readonly
     *
     * True both when the user is dragging around with touch gestures the view contents or the view is animating
     */
    Q_PROPERTY(bool moving READ moving NOTIFY movingChanged FINAL)

    /*!
     * \qmlproperty bool ColumnView::interactive
     *
     * True if it supports moving the contents by dragging
     */
    Q_PROPERTY(bool interactive READ interactive WRITE setInteractive NOTIFY interactiveChanged FINAL)

    /*!
     * \deprecated \qmlproperty bool ColumnView::acceptsMouse
     *
     * This property is deprecated and doesn't have any effect
     */
    Q_PROPERTY(bool acceptsMouse READ acceptsMouse WRITE setAcceptsMouse NOTIFY acceptsMouseChanged FINAL)

    // Default properties
    /*!
     * \qmlproperty list<Item> ColumnView::contentChildren
     *
     * Every column item the view contains
     */
    Q_PROPERTY(QQmlListProperty<QQuickItem> contentChildren READ contentChildren NOTIFY contentChildrenChanged FINAL)
    /*!
     * \qmlproperty list<QtObject> ColumnView::contentData
     * \qmldefault
     *
     * every item declared inside the view, both visual and non-visual items
     */
    Q_PROPERTY(QQmlListProperty<QObject> contentData READ contentData FINAL)

    /*!
     * \qmlproperty string ColumnView::savedState
     *
     * A JSon serialization of the columns widths.
     * When columnResizeMode is DynamicColumns, columns can be resized via mouse.
     * When this is the case, the sizes should be saved and restored on application startup.
     *
     * Example code for saving and restore, assuming that the application exposes a singleton
     * called App that has a "columnViewState" property that reads and writes to the config file:
     *
     * \qml
     *      Component.onCompleted: pageStack.columnView.savedState = App.columnViewState;
     *      columnView.onSavedStateChanged: {
     *          App.columnViewState = pageStack.columnView.savedState;
     *      }
     * \endqml
     */
    Q_PROPERTY(QString savedState READ savedState WRITE setSavedState NOTIFY savedStateChanged)

    Q_CLASSINFO("DefaultProperty", "contentData")

public:
    /*!
     * \value FixedColumns Every column is fixed at the same width of the columnWidth property
     * \value DynamicColumns Columns take their width from their implicitWidth
     * \value SingleColumn Only one column at a time is shown, as wide as the viewport, eventual reservedSpace on the column's attached property is ignored
     */
    enum ColumnResizeMode {
        FixedColumns = 0,
        DynamicColumns,
        SingleColumn,
    };
    Q_ENUM(ColumnResizeMode)

    ColumnView(QQuickItem *parent = nullptr);
    ~ColumnView() override;

    // QML property accessors
    ColumnResizeMode columnResizeMode() const;
    void setColumnResizeMode(ColumnResizeMode mode);

    qreal columnWidth() const;
    void setColumnWidth(qreal width);

    int currentIndex() const;
    void setCurrentIndex(int index);

    int scrollDuration() const;
    void setScrollDuration(int duration);

    bool separatorVisible() const;
    void setSeparatorVisible(bool visible);

    int count() const;

    qreal topPadding() const;
    void setTopPadding(qreal padding);

    qreal bottomPadding() const;
    void setBottomPadding(qreal padding);

    QQuickItem *currentItem();

    QList<QQuickItem *> visibleItems() const;
    QQuickItem *leadingVisibleItem() const;
    QQuickItem *trailingVisibleItem() const;

    QQuickItem *contentItem() const;

    QQmlListProperty<QQuickItem> contentChildren();
    QQmlListProperty<QObject> contentData();

    bool dragging() const;
    bool moving() const;
    qreal contentWidth() const;

    qreal contentX() const;
    void setContentX(qreal x) const;

    bool interactive() const;
    void setInteractive(bool interactive);

    bool acceptsMouse() const;
    void setAcceptsMouse(bool accepts);

    /*!
     * \qmlmethod Item ColumnView::get(int index)
     *
     * \brief This method gets the item at index, if available
     *
     * Note that if an invalid index is passed (either negative or greater
     * then depth - 1) nullptr will be returned
     *
     * \a index The index of the item to get.
     * \since 6.16
     */
    Q_INVOKABLE QQuickItem *get(int index);

    /*!
     * \qmlmethod Item ColumnView::pop(var item)
     *
     * \brief This method removes all the items after the specified item or
     * index from the view and returns the last item that was removed.
     *
     * Note that if the passed value is neither of the values said below, it
     * will return a nullptr.
     *
     * \a item the item to remove. It can be an item, index or not defined
     * in which case it will pop the last item.
     */
    Q_INVOKABLE QQuickItem *pop(const QVariant &item);

    /*!
     * \brief This method removes all the items after the specified item from
     * the view and returns the last item that was removed.
     *
     * \sa ::removeItem()
     *
     * \a the item where the iteration should stop at
     *
     * Returns the last item that has been removed
     */
    QQuickItem *pop(QQuickItem *item);

    /*!
     * \brief This method removes all the items after the specified position
     * from the view and returns the last item that was removed.
     *
     * It starts iterating from the last item to the first item calling
     * removeItem() for each of them until it reaches the specified position.
     *
     * \sa removeItem()
     *
     * \a index the position where the iteration should stop at
     *
     * Returnss the last item that has been removed
     */
    QQuickItem *pop(int index);

    /*!
     * \qmlmethod Item ColumnView::pop()
     *
     * \brief This method removes the last item from the view and returns it.
     *
     * This method calls removeItem() on the last item.
     *
     * \sa removeItem()
     *
     * Returns the removed item
     */
    Q_INVOKABLE QQuickItem *pop();

    /*!
     * \brief This method removes the specified item from the view.
     *
     * Items will be reparented to their old parent. If they have JavaScript
     * ownership and they didn't have an old parent, they will be destroyed.
     * CurrentIndex may be changed in order to keep the same currentItem
     *
     * \a item pointer to the item to remove
     *
     * Returns the removed item
     */
    QQuickItem *removeItem(QQuickItem *item);

    /*!
     * \brief This method removes an item at a given index from the view.
     *
     * This method calls removeItem(QQuickItem *item) to remove the item at
     * the specified index.
     *
     * \a index the index of the item which should be removed
     *
     * Returns the removed item
     */
    QQuickItem *removeItem(int index);

    QString savedState();
    void setSavedState(const QString &state);

    // QML attached property
    static ColumnViewAttached *qmlAttachedProperties(QObject *object);

public Q_SLOTS:
    /*!
     * Pushes a new item at the end of the view
     *
     * \a item the new item which will be reparented and managed
     */
    void addItem(QQuickItem *item);

    /*!
     * \qmlmethod Item ColumnView::removeItem(var item)
     *
     * \brief This method removes an item from the view.
     *
     * If the argument is a number, this method dispatches to removeItem(int index)
     * to remove an item by its index. Otherwise the argument should be the item
     * itself to be removed itself, and this method will dispatch to removeItem(QQuickItem *item).
     *
     * \a index the index of the item which should be removed, or the item itself
     *
     * Returns the removed item
     */
    Q_INVOKABLE QQuickItem *removeItem(const QVariant &item);

    /*!
     * Inserts a new item in the view at a given position.
     * The current Item will not be changed, currentIndex will be adjusted
     * accordingly if needed to keep the same current item.
     *
     * \a pos the position we want the new item to be inserted in
     *
     * \a item the new item which will be reparented and managed
     */
    void insertItem(int pos, QQuickItem *item);

    /*!
     * Replaces an item in the view at a given position with a new item.
     * The current Item and currentIndex will not be changed.
     *
     * \a pos the position we want the new item to be placed in
     *
     * \a item the new item which will be reparented and managed
     */
    void replaceItem(int pos, QQuickItem *item);

    /*!
     * Move an item inside the view.
     * The currentIndex property may be changed in order to keep currentItem the same.
     *
     * \a from the old position
     *
     * \a to the new position
     */
    void moveItem(int from, int to);

    /*!
     * Removes every item in the view.
     * Items will be reparented to their old parent.
     * If they have JavaScript ownership and they didn't have an old parent, they will be destroyed
     */
    void clear();

    /*!
     * Returnss true if the view contains the given item
     */
    bool containsItem(QQuickItem *item);

    /*!
     * Returns the visible item containing the point x, y in content coordinates.
     * If there is no item at the point specified, or the item is not visible null is returned.
     */
    QQuickItem *itemAt(qreal x, qreal y);

protected:
    void classBegin() override;
    void componentComplete() override;
    void updatePolish() override;
    void itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value) override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    bool childMouseEventFilter(QQuickItem *item, QEvent *event) override;
    bool event(QEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;

Q_SIGNALS:
    /*!
     * \qmlsignal ColumnView::itemInserted(int position, Item item)
     *
     * A new item has been inserted
     *
     * \a position where the page has been inserted
     *
     * \a item a pointer to the new item
     */
    void itemInserted(int position, QQuickItem *item);

    /*!
     * \qmlsignal ColumnView::itemRemoved(Item item)
     *
     * An item has just been removed from the view
     *
     * \a item a pointer to the item that has just been removed
     */
    void itemRemoved(QQuickItem *item);

    // Property notifiers
    void contentChildrenChanged();
    void columnResizeModeChanged();
    void columnWidthChanged();
    void currentIndexChanged();
    void currentItemChanged();
    void visibleItemsChanged();
    void countChanged();
    void draggingChanged();
    void movingChanged();
    void contentXChanged();
    void contentWidthChanged();
    void interactiveChanged();
    void acceptsMouseChanged();
    void scrollDurationChanged();
    void separatorVisibleChanged();
    void leadingVisibleItemChanged();
    void trailingVisibleItemChanged();
    void topPaddingChanged();
    void bottomPaddingChanged();
    void savedStateChanged();

private:
    static void contentChildren_append(QQmlListProperty<QQuickItem> *prop, QQuickItem *object);
    static qsizetype contentChildren_count(QQmlListProperty<QQuickItem> *prop);
    static QQuickItem *contentChildren_at(QQmlListProperty<QQuickItem> *prop, qsizetype index);
    static void contentChildren_clear(QQmlListProperty<QQuickItem> *prop);

    static void contentData_append(QQmlListProperty<QObject> *prop, QObject *object);
    static qsizetype contentData_count(QQmlListProperty<QObject> *prop);
    static QObject *contentData_at(QQmlListProperty<QObject> *prop, qsizetype index);
    static void contentData_clear(QQmlListProperty<QObject> *prop);

    QList<QObject *> m_contentData;

    ContentItem *m_contentItem;
    QPointer<QQuickItem> m_currentItem;
    QHash<int, qreal> m_state;

    int m_currentIndex = -1;
    qreal m_topPadding = 0;
    qreal m_bottomPadding = 0;

    bool m_interactive = true;
    // The user is dragging horizontally the ColumnView
    bool m_dragging = false;
    // The user is dragging vertically the contents of a page
    bool m_verticalScrollIntercepted = false;
    bool m_moving = false;
    bool m_separatorVisible = true;
    bool m_complete = false;
    bool m_acceptsMouse = false;
};

QML_DECLARE_TYPEINFO(ColumnView, QML_HAS_ATTACHED_PROPERTIES)
