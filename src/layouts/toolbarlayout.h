/*
 * SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

#ifndef TOOLBARLAYOUT_H
#define TOOLBARLAYOUT_H

#include <QQuickItem>
#include <memory>

class ToolBarLayoutPrivate;

class ToolBarLayoutAttached : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *action READ action CONSTANT FINAL)
public:
    ToolBarLayoutAttached(QObject *parent = nullptr);

    QObject *action() const;
    void setAction(QObject *action);

private:
    QObject *m_action = nullptr;
};

/*!
 * \qmltype ToolBarLayout
 * \inqmlmodule org.kde.kirigami.layouts
 * \inherits Item
 *
 * \brief An item that creates delegates for actions and lays them out in a row.
 *
 * This effectively combines RowLayout and Repeater in a single item, with the
 * addition of some extra performance enhancing tweaks. It will create instances
 * of fullDelegate and itemDelegate for each action in actions. These are
 * then positioned horizontally. Any action that ends up being placed outside
 * the width of the item is hidden and will be part of hiddenActions.
 *
 * The items created as delegates are always created asynchronously, to avoid
 * creation lag spikes. Each delegate has access to the action it was created
 * for through the action attached property.
 */
class ToolBarLayout : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(ToolBarLayoutAttached)
    /*!
     * \qmlproperty list<QtObject> ToolBarLayout::actions
     *
     * The actions this layout should create delegates for.
     */
    Q_PROPERTY(QQmlListProperty<QObject> actions READ actionsProperty NOTIFY actionsChanged FINAL)
    /*!
     * \qmlproperty list<QtObject> ToolBarLayout::hiddenActions
     *
     * A list of actions that do not fit in the current view and are thus hidden.
     */
    Q_PROPERTY(QList<QObject *> hiddenActions READ hiddenActions NOTIFY hiddenActionsChanged FINAL)
    /*!
     * \qmlproperty Component ToolBarLayout::fullDelegate
     *
     * A component that is used to create full-size delegates from.
     *
     * Each delegate has three states, it can be full-size, icon-only or hidden.
     * By default, the full-size delegate is used. When the action has the
     * DisplayHint.IconOnly hint set, it will always use the iconDelegate. When
     * it has the DisplayHint.KeepVisible hint set, it will use the full-size
     * delegate when it fits. If not, it will use the iconDelegate, unless even
     * that does not fit, in which case it will still be hidden.
     */
    Q_PROPERTY(QQmlComponent *fullDelegate READ fullDelegate WRITE setFullDelegate NOTIFY fullDelegateChanged FINAL)
    /*!
     * \qmlproperty Component ToolBarLayout::iconDelegate
     *
     * A component that is used to create icon-only delegates from.
     *
     * \sa fullDelegate
     */
    Q_PROPERTY(QQmlComponent *iconDelegate READ iconDelegate WRITE setIconDelegate NOTIFY iconDelegateChanged FINAL)
    /*!
     * \qmlproperty Component ToolBarLayout::separatorDelegate
     *
     * A component that is used to create separator delegates from.
     *
     * \since 6.7
     *
     * \sa fullDelegate
     */
    Q_PROPERTY(QQmlComponent *separatorDelegate READ separatorDelegate WRITE setSeparatorDelegate NOTIFY separatorDelegateChanged FINAL)
    /*!
     * \qmlproperty Component ToolBarLayout::moreButton
     *
     * A component that is used to create the "more button" item from.
     *
     * The more button is shown when there are actions that do not fit the
     * current view. It is intended to have functionality to show these hidden
     * actions, like popup a menu with them showing.
     */
    Q_PROPERTY(QQmlComponent *moreButton READ moreButton WRITE setMoreButton NOTIFY moreButtonChanged FINAL)
    /*!
     * \qmlproperty real ToolBarLayout::spacing
     *
     * The amount of spacing between individual delegates.
     */
    Q_PROPERTY(qreal spacing READ spacing WRITE setSpacing NOTIFY spacingChanged FINAL)
    /*!
     * \qmlproperty Qt.Alignment ToolBarLayout::alignment
     *
     * How to align the delegates within this layout.
     *
     * When there is more space available than required by the visible delegates,
     * we need to determine how to place the delegates. This property determines
     * how to do that. Note that the moreButton, if visible, will always be
     * placed at the end of the layout.
     */
    Q_PROPERTY(Qt::Alignment alignment READ alignment WRITE setAlignment NOTIFY alignmentChanged FINAL)
    /*!
     * \qmlproperty real ToolBarLayout::visibleWidth
     *
     * The combined width of visible delegates in this layout.
     */
    Q_PROPERTY(qreal visibleWidth READ visibleWidth NOTIFY visibleWidthChanged FINAL)
    /*!
     * \qmlproperty real ToolBarLayout::minimumWidth
     *
     * The minimum width this layout can have.
     *
     * This is equal to the width of the moreButton.
     */
    Q_PROPERTY(qreal minimumWidth READ minimumWidth NOTIFY minimumWidthChanged FINAL)
    /*!
     * \qmlproperty Qt.LayoutDirection ToolBarLayout::layoutDirection
     *
     * Which direction to layout in.
     *
     * This is primarily intended to support right-to-left layouts. When set to
     * LeftToRight, delegates will be layout with the first item on the left and
     * following items to the right of that. The more button will be placed at
     * the rightmost position. Alignment flags work normally.
     *
     * When set to RightToLeft, delegates will be layout with the first item on
     * the right and following items to the left of that. The more button will
     * be placed at the leftmost position. Alignment flags are inverted, so
     * AlignLeft will align items to the right, and vice-versa.
     */
    Q_PROPERTY(Qt::LayoutDirection layoutDirection READ layoutDirection WRITE setLayoutDirection NOTIFY layoutDirectionChanged FINAL)
    /*!
     * \qmlproperty enumeration ToolBarLayout::heightMode
     * How to handle items that do not match the toolbar's height.
     *
     * When toolbar items do not match the height of the toolbar, there are
     * several ways we can deal with this. This property sets the preferred way.
     *
     * Available are:
     * \list
     * \li AlwaysCenter Always center items, allowing them to go outside the bounds of the layout if they are larger
     * \li AlwaysFill Always match the height of the layout. Larger items will be reduced in height, smaller items will be increased
     * \li ConstrainIfLarger If the item is larger than the toolbar, reduce its height. Otherwise center it in the toolbar
     * \endlist
     *
     * The default is HeightMode::ConstrainIfLarger .
     */
    Q_PROPERTY(HeightMode heightMode READ heightMode WRITE setHeightMode NOTIFY heightModeChanged FINAL)

    /*!
     * \qmlattachedproperty QtObject ToolBarLayout::action
     *
     * The action this delegate was created for.
     */

public:
    using ActionsProperty = QQmlListProperty<QObject>;

    enum HeightMode {
        AlwaysCenter,
        AlwaysFill,
        ConstrainIfLarger,
    };
    Q_ENUM(HeightMode)

    ToolBarLayout(QQuickItem *parent = nullptr);
    ~ToolBarLayout() override;

    ActionsProperty actionsProperty() const;

    void addAction(QObject *action);

    void removeAction(QObject *action);

    void clearActions();
    Q_SIGNAL void actionsChanged();

    QList<QObject *> hiddenActions() const;
    Q_SIGNAL void hiddenActionsChanged();

    QQmlComponent *fullDelegate() const;
    void setFullDelegate(QQmlComponent *newFullDelegate);
    Q_SIGNAL void fullDelegateChanged();

    QQmlComponent *iconDelegate() const;
    void setIconDelegate(QQmlComponent *newIconDelegate);
    Q_SIGNAL void iconDelegateChanged();

    QQmlComponent *separatorDelegate() const;
    void setSeparatorDelegate(QQmlComponent *newSeparatorDelegate);
    Q_SIGNAL void separatorDelegateChanged();

    QQmlComponent *moreButton() const;
    void setMoreButton(QQmlComponent *newMoreButton);
    Q_SIGNAL void moreButtonChanged();

    qreal spacing() const;
    void setSpacing(qreal newSpacing);
    Q_SIGNAL void spacingChanged();

    Qt::Alignment alignment() const;
    void setAlignment(Qt::Alignment newAlignment);
    Q_SIGNAL void alignmentChanged();

    qreal visibleWidth() const;
    Q_SIGNAL void visibleWidthChanged();

    qreal minimumWidth() const;
    Q_SIGNAL void minimumWidthChanged();

    Qt::LayoutDirection layoutDirection() const;
    void setLayoutDirection(Qt::LayoutDirection &newLayoutDirection);
    Q_SIGNAL void layoutDirectionChanged();

    HeightMode heightMode() const;
    void setHeightMode(HeightMode newHeightMode);
    Q_SIGNAL void heightModeChanged();

    /*!
     * \qmlmethod void ToolBarLayout::relayout()
     * Queue a relayout of this layout.
     *
     * \note The layouting happens during the next scene graph polishing phase.
     */
    Q_SLOT void relayout();

    static ToolBarLayoutAttached *qmlAttachedProperties(QObject *object)
    {
        return new ToolBarLayoutAttached(object);
    }

protected:
    void componentComplete() override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &data) override;
    void updatePolish() override;

private:
    friend class ToolBarLayoutPrivate;
    const std::unique_ptr<ToolBarLayoutPrivate> d;
};

QML_DECLARE_TYPEINFO(ToolBarLayout, QML_HAS_ATTACHED_PROPERTIES)

#endif // TOOLBARLAYOUT_H
