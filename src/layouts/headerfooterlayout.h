/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
#ifndef HEADERFOOTERLAYOUT_H
#define HEADERFOOTERLAYOUT_H

#include <QQuickItem>
#include <qtmetamacros.h>

/*!
 * \qmltype HeaderFooterLayout
 * \inqmlmodule org.kde.kirigami.layouts
 *
 * \brief Replicates a little part of what Page does.
 *
 * It's a container with 3 properties, header, contentItem and footer
 * which will be laid out oone on top of each other.
 *
 * It works better than a ColumnLayout when the elements are to be
 * defined by properties by the user, which would require ugly
 * reparenting dances and container items to
 * maintain the layout well behaving.
 */
class HeaderFooterLayout : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
    /*!
     * \qmlproperty Item HeaderFooterLayout::header
     * \brief This property holds the page header item.
     *
     * The header item is positioned to the top,
     * and resized to the width of the page. The default value is null.
     */
    Q_PROPERTY(QQuickItem *header READ header WRITE setHeader NOTIFY headerChanged FINAL)

    /*!
     * \qmlproperty Item HeaderFooterLayout::contentItem
     * \brief This property holds the visual content Item.
     *
     * It will be resized both in width and height with the layout resizing.
     * Its height will be resized to still have room for the heder and footer
     */
    Q_PROPERTY(QQuickItem *contentItem READ contentItem WRITE setContentItem NOTIFY contentItemChanged FINAL)

    /*!
     * \qmlproperty Item HeaderFooterLayout::footer
     * \brief This property holds the page footer item.
     *
     * The footer item is positioned to the bottom,
     * and resized to the width of the page. The default value is null.
     */
    Q_PROPERTY(QQuickItem *footer READ footer WRITE setFooter NOTIFY footerChanged FINAL)

    /*!
     * \qmlproperty real HeaderFooterLayout::spacing
     * \brief Space between contentItem and the header and footer items.
     *
     * The content Item of the page will be positioned at this distance in pixels
     * from the header and footer Items. The default value is zero.
     *
     * @since 6.13
     */
    Q_PROPERTY(qreal spacing READ spacing WRITE setSpacing NOTIFY spacingChanged FINAL)

public:
    HeaderFooterLayout(QQuickItem *parent = nullptr);
    ~HeaderFooterLayout() override;

    void setHeader(QQuickItem *item);
    QQuickItem *header();

    void setContentItem(QQuickItem *item);
    QQuickItem *contentItem();

    void setFooter(QQuickItem *item);
    QQuickItem *footer();

    void setSpacing(qreal spacing);
    qreal spacing() const;

    /*!
     * \qmlmethod void HeaderFooterLayout::forceLayout()
     * \brief HeaderFooterLayout normally positions its header, footer and
     * contentItem once per frame (at polish event). This method forces the it
     * to recalculate the layout immediately.
     */
    Q_INVOKABLE void forceLayout();

Q_SIGNALS:
    void headerChanged();
    void spacingChanged();
    void contentItemChanged();
    void footerChanged();

protected:
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void componentComplete() override;
    void updatePolish() override;

private:
    void markAsDirty();
    void performLayout();
    void updateImplicitSize();
    void disconnectItem(QQuickItem *item);

    QPointer<QQuickItem> m_header;
    QPointer<QQuickItem> m_contentItem;
    QPointer<QQuickItem> m_footer;

    qreal m_spacing = 0;

    bool m_isDirty : 1;
    bool m_performingLayout : 1;
};

#endif
