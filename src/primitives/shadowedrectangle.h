/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QQuickItem>
#include <memory>

#include <QQmlEngine>

class PaintedRectangleItem;

class BorderGroup : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

    Q_PROPERTY(qreal width READ width WRITE setWidth NOTIFY changed FINAL)

    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY changed FINAL)

public:
    explicit BorderGroup(QObject *parent = nullptr);

    qreal width() const;
    void setWidth(qreal newWidth);

    QColor color() const;
    void setColor(const QColor &newColor);

    Q_SIGNAL void changed();

    inline bool isEnabled() const
    {
        return !qFuzzyIsNull(m_width);
    }

private:
    qreal m_width = 0.0;
    QColor m_color = Qt::black;
};

class ShadowGroup : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

    Q_PROPERTY(qreal size READ size WRITE setSize NOTIFY changed FINAL)

    Q_PROPERTY(qreal xOffset READ xOffset WRITE setXOffset NOTIFY changed FINAL)

    Q_PROPERTY(qreal yOffset READ yOffset WRITE setYOffset NOTIFY changed FINAL)

    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY changed FINAL)

public:
    explicit ShadowGroup(QObject *parent = nullptr);

    qreal size() const;
    void setSize(qreal newSize);

    qreal xOffset() const;
    void setXOffset(qreal newXOffset);

    qreal yOffset() const;
    void setYOffset(qreal newYOffset);

    QColor color() const;
    void setColor(const QColor &newShadowColor);

    Q_SIGNAL void changed();

private:
    qreal m_size = 0.0;
    qreal m_xOffset = 0.0;
    qreal m_yOffset = 0.0;
    QColor m_color = Qt::black;
};

class CornersGroup : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

    Q_PROPERTY(qreal topLeftRadius READ topLeft WRITE setTopLeft NOTIFY changed FINAL)

    Q_PROPERTY(qreal topRightRadius READ topRight WRITE setTopRight NOTIFY changed FINAL)

    Q_PROPERTY(qreal bottomLeftRadius READ bottomLeft WRITE setBottomLeft NOTIFY changed FINAL)

    Q_PROPERTY(qreal bottomRightRadius READ bottomRight WRITE setBottomRight NOTIFY changed FINAL)

public:
    explicit CornersGroup(QObject *parent = nullptr);

    qreal topLeft() const;
    void setTopLeft(qreal newTopLeft);

    qreal topRight() const;
    void setTopRight(qreal newTopRight);

    qreal bottomLeft() const;
    void setBottomLeft(qreal newBottomLeft);

    qreal bottomRight() const;
    void setBottomRight(qreal newBottomRight);

    Q_SIGNAL void changed();

    QVector4D toVector4D(float all) const;

private:
    float m_topLeft = -1.0;
    float m_topRight = -1.0;
    float m_bottomLeft = -1.0;
    float m_bottomRight = -1.0;
};

/*!
 * \qmltype ShadowedRectangle
 * \inqmlmodule org.kde.kirigami.primitives
 *
 * \brief A rectangle with a shadow behind it.
 *
 * This item will render a rectangle, with a shadow below it. The rendering is done
 * using distance fields, which provide greatly improved performance. The shadow is
 * rendered outside of the item's bounds, so the item's width and height are the
 * rectangle's width and height.
 *
 * \since 5.69
 */
class ShadowedRectangle : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
    /*!
     * \qmlproperty real ShadowedRectangle::radius
     *
     * \brief This property holds the radii of the rectangle's corners.
     *
     * This is the amount of rounding to apply to all of the rectangle's
     * corners, in pixels. Each corner can have a different radius.
     *
     * default: 0
     */
    Q_PROPERTY(qreal radius READ radius WRITE setRadius NOTIFY radiusChanged FINAL)

    /*!
     * \qmlproperty color ShadowedRectangle::color
     * \brief This property holds the rectangle's color.
     *
     * Full RGBA colors are supported.
     *
     * default: Qt.white
     */
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged FINAL)

    /*!
     * \qmlproperty real ShadowedRectangle::border.width
     * \qmlproperty color ShadowedRectangle::border.color
     *
     * \brief This property holds the border's grouped property.
     *
     * width: The border's width in pixels. Default: 0
     *
     * color: The border's color. Full RGBA colors are supported. Default: Qt.black
     *
     * Example usage:
     * \code
     * Kirigami.ShadowedRectangle {
     *     border.width: 2
     *     border.color: Kirigami.Theme.textColor
     * }
     * \endcode
     */
    Q_PROPERTY(BorderGroup *border READ border CONSTANT FINAL)

    /*!
     * \qmlproperty real ShadowedRectangle::shadow.size
     * \qmlproperty real ShadowedRectangle::shadow.xOffset
     * \qmlproperty real ShadowedRectangle::shadow.yOffset
     * \qmlproperty color ShadowedRectangle::shadow.color
     *
     * \brief This property group holds the shadow's properties.
     *
     * size: The shadow's approximate size in pixels. Note: The actual shadow size can be less than this value due to falloff. Default: 0px
     *
     * xOffset: The shadow's offset in pixels on the X axis. Default: 0px
     *
     * yOffset: The shadow's offset in pixels on the Y axis. Default: 0px
     *
     * color: The shadow's color. Full RGBA colors are supported. Default: Qt.black
     *
     * Example usage:
     * \code
     * Kirigami.ShadowedRectangle {
     *     shadow.size: 20
     *     shadow.xOffset: 5
     *     shadow.yOffset: 5
     * }
     * \endcode
     */
    Q_PROPERTY(ShadowGroup *shadow READ shadow CONSTANT FINAL)

    /*!
     * \qmlproperty real ShadowedRectangle::corners.topLeftRadius
     * \qmlproperty real ShadowedRectangle::corners.topRightRadius
     * \qmlproperty real ShadowedRectangle::corners.bottomLeftRadius
     * \qmlproperty real ShadowedRectangle::corners.bottomRightRadius
     *
     * \brief This property holds the corners grouped property
     *
     * Note that the values from this group override the radius property for the
     * corner they affect.
     *
     * Setting any value to -1 indicates that the value should be ignored.
     *
     * The default value is -1
     *
     * Example usage:
     * \code
     * Kirigami.ShadowedRectangle {
     *     corners.topLeftRadius: 4
     *     corners.topRightRadius: 5
     *     corners.bottomLeftRadius: 2
     *     corners.bottomRightRadius: 10
     * \endcode
     */
    Q_PROPERTY(CornersGroup *corners READ corners CONSTANT FINAL)

    /*!
     * \qmlproperty enumeration ShadowedRectangle::renderType
     *
     * \brief This property holds the rectangle's render mode.
     *
     * \qmlenumeratorsfrom ShadowedRectangle::RenderType
     *
     * default: RenderType.Auto
     */
    Q_PROPERTY(RenderType renderType READ renderType WRITE setRenderType NOTIFY renderTypeChanged FINAL)

    /*!
     * \qmlproperty bool ShadowedRectangle::softwareRendering
     *
     * \brief This property tells whether software rendering is being used.
     *
     * default: false
     */
    Q_PROPERTY(bool softwareRendering READ isSoftwareRendering NOTIFY softwareRenderingChanged FINAL)

public:
    ShadowedRectangle(QQuickItem *parent = nullptr);
    ~ShadowedRectangle() override;

    /*!
     * \brief Available rendering types for ShadowedRectangle.
     *
     * \value Auto Automatically determine the optimal rendering type. This will use the highest rendering quality possible, falling back to lower quality if
     * the hardware doesn't support it. It will use software rendering if the QtQuick scene graph is set to use software rendering.
     * \value HighQuality Use the highest rendering quality possible, even if the hardware might not be able to handle it normally.
     * \value LowQuality Use the lowest rendering quality, even if the hardware could handle higher quality rendering. This might result in certain effects
     * being omitted, like shadows.
     * \value Software Always use software rendering for this rectangle. Software rendering is intended as a fallback when the QtQuick scene graph is configured
     * to use software rendering. It will result in a number of missing features, like shadows and multiple corner radii.
     */
    enum RenderType {
        Auto,
        HighQuality,
        LowQuality,
        Software
    };
    Q_ENUM(RenderType)

    BorderGroup *border() const;
    ShadowGroup *shadow() const;
    CornersGroup *corners() const;

    qreal radius() const;
    void setRadius(qreal newRadius);
    Q_SIGNAL void radiusChanged();

    QColor color() const;
    void setColor(const QColor &newColor);
    Q_SIGNAL void colorChanged();

    RenderType renderType() const;
    void setRenderType(RenderType renderType);
    Q_SIGNAL void renderTypeChanged();

    void componentComplete() override;

    bool isSoftwareRendering() const;

Q_SIGNALS:
    void softwareRenderingChanged();

protected:
    PaintedRectangleItem *softwareItem() const;
    void itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value) override;
    QSGNode *updatePaintNode(QSGNode *node, QQuickItem::UpdatePaintNodeData *data) override;

private:
    void checkSoftwareItem();
    const std::unique_ptr<BorderGroup> m_border;
    const std::unique_ptr<ShadowGroup> m_shadow;
    const std::unique_ptr<CornersGroup> m_corners;
    qreal m_radius = 0.0;
    QColor m_color = Qt::white;
    RenderType m_renderType = RenderType::Auto;
    PaintedRectangleItem *m_softwareItem = nullptr;
};
