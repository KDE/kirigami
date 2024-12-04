/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include "shadowedrectangle.h"

/*!
 * \qmltype ShadowedTexture
 * \inqmlmodule org.kde.kirigami.primitives
 *
 * \brief A rectangle with a shadow, using a Item as texture.
 *
 * This item will render a source item, with a shadow below it. The rendering is done
 * using distance fields, which provide greatly improved performance. The shadow is
 * rendered outside of the item's bounds, so the item's width and height are the
 * rectangle's width and height.
 *
 * \inherits ShadowedRectangle
 *
 * \since 5.69
 */
class ShadowedTexture : public ShadowedRectangle
{
    Q_OBJECT
    QML_ELEMENT

    /*!
     * \qmlproperty Item ShadowedTexture::source
     *
     * This property holds the source item that will get rendered with the
     * shadow.
     */
    Q_PROPERTY(QQuickItem *source READ source WRITE setSource NOTIFY sourceChanged FINAL)

public:
    ShadowedTexture(QQuickItem *parent = nullptr);
    ~ShadowedTexture() override;

    QQuickItem *source() const;
    void setSource(QQuickItem *newSource);
    Q_SIGNAL void sourceChanged();

protected:
    QSGNode *updatePaintNode(QSGNode *node, QQuickItem::UpdatePaintNodeData *data) override;

private:
    QQuickItem *m_source = nullptr;
    bool m_sourceChanged = false;
};
