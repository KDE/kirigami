/*
 *  SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
#ifndef PADDING_H
#define PADDING_H

#include <QQuickItem>
#include <qtmetamacros.h>

class PaddingPrivate;

/*!
 * \qmltype Padding
 * \inqmlmodule org.kde.kirigami.layouts
 *
 * \brief This item simply adds an external padding to contentItem's size.
 *
 * Padding item behaves similarly to Control::padding,
 * but is more lightweight and thus efficient. Its implicit size is set
 * to that of its contentItem's implicit size plus padding.
 *
 * \code
 * import QtQuick.Controls as QQC2
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.Padding {
 *     padding: Kirigami.Units.largeSpacing
 *     contentItem: QQC2.Button {}
 * }
 * \endcode
 *
 * With this component it is possible to add external paddings as a
 * placeholder for an item, whereas with QtQuick Layouts} you would need to
 * manually assign or bind attached properties whenever content item changes.
 *
 * \code
 * import QtQuick
 * import QtQuick.Layouts
 * import QtQuick.Controls as QQC2
 * import org.kde.kirigami as Kirigami
 *
 * ColumnLayout {
 *     property alias contentItem: container.contentItem
 *
 *     Kirigami.Heading {
 *         Layout.fillWidth: true
 *         Layout.margins: Kirigami.Units.largeSpacing
 *     }
 *
 *     Kirigami.Padding {
 *         id: container
 *         Layout.fillWidth: true
 *         padding: Kirigami.Units.largeSpacing
 *     }
 * }
 * \endcode
 *
 * \since 6.0
 */
class Padding : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT

    /*!
     * \qmlproperty Item Padding::contentItem
     *
     * \brief This property holds the visual content Item.
     *
     * It will automatically resized taking into account all the paddings
     */
    Q_PROPERTY(QQuickItem *contentItem READ contentItem WRITE setContentItem NOTIFY contentItemChanged FINAL)

    /*!
     * \qmlproperty real Padding::padding
     *
     * \brief This property holds the default padding.
     *
     * Padding adds a space between each edge of  this ITem and its contentItem, effectively controlling its size.
     * To specify a padding value for a specific edge of the control, set its relevant property:
     * \list
     * \li leftPadding
     * \li rightPadding
     * \li topPadding
     * \li bottomPadding
     * \endlist
     */
    Q_PROPERTY(qreal padding READ padding WRITE setPadding NOTIFY paddingChanged RESET resetPadding FINAL)

    /*!
     * \qmlproperty real Padding::horizontalPadding
     *
     * \brief This property holds the horizontal padding.
     *
     * Unless explicitly set, the value is equal to padding.
     */
    Q_PROPERTY(qreal horizontalPadding READ horizontalPadding WRITE setHorizontalPadding NOTIFY horizontalPaddingChanged RESET resetHorizontalPadding FINAL)

    /*!
     * \qmlproperty real Padding::verticalPadding
     *
     * \brief This property holds the vertical padding.
     *
     * Unless explicitly set, the value is equal to padding.
     */
    Q_PROPERTY(qreal verticalPadding READ verticalPadding WRITE setVerticalPadding NOTIFY verticalPaddingChanged RESET resetVerticalPadding FINAL)

    /*!
     * \qmlproperty real Padding::leftPadding
     *
     * \brief This property holds the padding on the left side.
     *
     * Unless explicitly set, it falls back to horizontalPadding and then to padding.
     * This always refers to the actual left, it won't be flipped on RTL layouts.
     */
    Q_PROPERTY(qreal leftPadding READ leftPadding WRITE setLeftPadding NOTIFY leftPaddingChanged RESET resetLeftPadding FINAL)

    /*!
     * \qmlproperty real Padding::topPadding
     *
     * \brief the padding on the top side.
     *
     * Unless explicitly set, it falls back to verticalPadding and then to padding.
     */
    Q_PROPERTY(qreal topPadding READ topPadding WRITE setTopPadding NOTIFY topPaddingChanged RESET resetTopPadding FINAL)

    /*!
     * \qmlproperty real Padding::rightPadding
     *
     * \brief This property holds the padding on the right side.
     *
     * Unless explicitly set, it falls back to horizontalPadding and then to padding.
     * This always refers to the actual right, it won't be flipped on RTL layouts.
     */
    Q_PROPERTY(qreal rightPadding READ rightPadding WRITE setRightPadding NOTIFY rightPaddingChanged RESET resetRightPadding FINAL)

    /*!
     * \qmlproperty real Padding::bottomPadding
     *
     * \brief This property holds the padding on the bottom side.
     *
     * Unless explicitly set, it falls back to verticalPadding and then to padding.
     */
    Q_PROPERTY(qreal bottomPadding READ bottomPadding WRITE setBottomPadding NOTIFY bottomPaddingChanged RESET resetBottomPadding FINAL)

    /*!
     * \qmlproperty real Padding::availableWidth
     * \readonly
     *
     * \brief The width available to the contentItem after deducting horizontal padding from the width of the Padding.
     */
    Q_PROPERTY(qreal availableWidth READ availableWidth NOTIFY availableWidthChanged FINAL)

    /*!
     * \qmlproperty real Padding::availableHeight
     * \readonly
     *
     * \brief The height available to the contentItem after deducting vertical padding from the width of the Padding.
     */
    Q_PROPERTY(qreal availableHeight READ availableHeight NOTIFY availableHeightChanged FINAL)

    /*!
     * \qmlproperty real Padding::implicitContentWidth
     * \readonly
     *
     * \brief The implicitWidth of its contentItem, or 0 if not present.
     */
    Q_PROPERTY(qreal implicitContentWidth READ implicitContentWidth NOTIFY implicitContentWidthChanged FINAL)

    /*!
     * \qmlproperty real Padding::implicitContentHeight
     * \readonly
     *
     * \brief The implicitHeight of its contentItem, or 0 if not present.
     */
    Q_PROPERTY(qreal implicitContentHeight READ implicitContentHeight NOTIFY implicitContentHeightChanged FINAL)

public:
    Padding(QQuickItem *parent = nullptr);
    ~Padding() override;

    void setContentItem(QQuickItem *item);
    QQuickItem *contentItem();

    void setPadding(qreal padding);
    void resetPadding();
    qreal padding() const;

    void setHorizontalPadding(qreal padding);
    void resetHorizontalPadding();
    qreal horizontalPadding() const;

    void setVerticalPadding(qreal padding);
    void resetVerticalPadding();
    qreal verticalPadding() const;

    void setLeftPadding(qreal padding);
    void resetLeftPadding();
    qreal leftPadding() const;

    void setTopPadding(qreal padding);
    void resetTopPadding();
    qreal topPadding() const;

    void setRightPadding(qreal padding);
    void resetRightPadding();
    qreal rightPadding() const;

    void setBottomPadding(qreal padding);
    void resetBottomPadding();
    qreal bottomPadding() const;

    qreal availableWidth() const;
    qreal availableHeight() const;

    qreal implicitContentWidth() const;
    qreal implicitContentHeight() const;

Q_SIGNALS:
    void contentItemChanged();
    void paddingChanged();
    void horizontalPaddingChanged();
    void verticalPaddingChanged();
    void leftPaddingChanged();
    void topPaddingChanged();
    void rightPaddingChanged();
    void bottomPaddingChanged();
    void availableHeightChanged();
    void availableWidthChanged();
    void implicitContentWidthChanged();
    void implicitContentHeightChanged();

protected:
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void updatePolish() override;
    void componentComplete() override;

private:
    friend class PaddingPrivate;
    const std::unique_ptr<PaddingPrivate> d;
};

#endif
