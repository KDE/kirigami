/*
 *  SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QIcon>
#include <QPointer>
#include <QQuickItem>
#include <QVariant>

#include <QQmlEngine>

class QNetworkReply;
class QQuickWindow;
class QPropertyAnimation;

namespace Kirigami
{
namespace Platform
{
class PlatformTheme;
class Units;
}
}

/**
 * Class for rendering an icon in UI.
 */
class Icon : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT

    /**
     * The source of this icon. An `Icon` can pull from:
     *
     * * The icon theme:
     * @include icon/IconThemeSource.qml
     * * The filesystem:
     * @include icon/FilesystemSource.qml
     * * Remote URIs:
     * @include icon/InternetSource.qml
     * * Custom providers:
     * @include icon/CustomSource.qml
     * * Your application's bundled resources:
     * @include icon/ResourceSource.qml
     *
     * @note See https://doc.qt.io/qt-5/qtquickcontrols2-icons.html for how to
     * bundle icon themes in your application to refer to them by name instead of
     * by resource URL.
     *
     * @note Use `fallback` to provide a fallback theme name for icons.
     *
     * @note Cuttlefish is a KDE application that lets you view all the icons that
     * you can use for your application. It offers a number of useful features such
     * as previews of their appearance across different installed themes, previews
     * at different sizes, and more. You might find it a useful tool when deciding
     * on which icons to use in your application.
     */
    Q_PROPERTY(QVariant source READ source WRITE setSource NOTIFY sourceChanged FINAL)

    /**
     * The name of a fallback icon to load from the icon theme when the `source`
     * cannot be found. The default fallback icon is `"unknown"`.
     *
     * @include icon/Fallback.qml
     *
     * @note This will only be loaded if source is unavailable (e.g. it doesn't exist, or network issues have prevented loading).
     */
    Q_PROPERTY(QString fallback READ fallback WRITE setFallback NOTIFY fallbackChanged FINAL)

    /**
     * The name of an icon from the icon theme to show while the icon set in `source` is
     * being loaded. This is primarily relevant for remote sources, or those using slow-
     * loading image providers. The default temporary icon is `"image-x-icon"`
     *
     * @note This will only be loaded if the source is a type which can be so long-loading
     * that a temporary image makes sense (e.g. a remote image, or from an ImageProvider
     * of the type QQmlImageProviderBase::ImageResponse)
     *
     * @since 5.15
     */
    Q_PROPERTY(QString placeholder READ placeholder WRITE setPlaceholder NOTIFY placeholderChanged FINAL)

    /**
     * Whether this icon will use the QIcon::Active mode when drawing the icon,
     * resulting in a graphical effect being applied to the icon to indicate that
     * it is currently active.
     *
     * This is typically used to indicate when an item is being hovered or pressed.
     *
     * @image html icon/active.png
     *
     * The color differences under the default KDE color palette, Breeze. Note
     * that a dull highlight background is typically displayed behind active icons and
     * it is recommended to add one if you are creating a custom component.
     */
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged FINAL)

    /**
     * Whether this icon's `source` is valid and it is being used.
     */
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged FINAL)

    /**
     * Whether this icon will use the QIcon::Selected mode when drawing the icon,
     * resulting in a graphical effect being applied to the icon to indicate that
     * it is currently selected.
     *
     * This is typically used to indicate when a list item is currently selected.
     *
     * @image html icon/selected.png
     *
     * The color differences under the default KDE color palette, Breeze. Note
     * that a blue background is typically displayed behind selected elements.
     */
    Q_PROPERTY(bool selected READ selected WRITE setSelected NOTIFY selectedChanged FINAL)

    /**
     * Whether this icon will be treated as a mask. When an icon is being used
     * as a mask, all non-transparent colors are replaced with the color provided in the Icon's
     * @link Icon::color color @endlink property.
     *
     * @see color
     */
    Q_PROPERTY(bool isMask READ isMask WRITE setIsMask NOTIFY isMaskChanged FINAL)

    /**
     * The color to use when drawing this icon when `isMask` is enabled.
     * If this property is not set or is `Qt::transparent`, the icon will use
     * the text or the selected text color, depending on if `selected` is set to
     * true.
     */
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged FINAL)

    /**
     * Whether the icon is correctly loaded, is asynchronously loading or there was an error.
     * Note that image loading will not be initiated until the item is shown, so if the Icon is not visible,
     * it can only have Null or Loading states.
     * @since 5.15
     */
    Q_PROPERTY(Icon::Status status READ status NOTIFY statusChanged FINAL)

    /**
     * The width of the painted area measured in pixels. This will be smaller than or
     * equal to the width of the area taken up by the Item itself. This can be 0.
     *
     * @since 5.15
     */
    Q_PROPERTY(qreal paintedWidth READ paintedWidth NOTIFY paintedAreaChanged FINAL)

    /**
     * The height of the painted area measured in pixels. This will be smaller than or
     * equal to the height of the area taken up by the Item itself. This can be 0.
     *
     * @since 5.15
     */
    Q_PROPERTY(qreal paintedHeight READ paintedHeight NOTIFY paintedAreaChanged FINAL)

    /**
     * If set, icon will blend when the source is changed
     */
    Q_PROPERTY(bool animated READ isAnimated WRITE setAnimated NOTIFY animatedChanged FINAL)

    /**
     * If set, icon will round the painted size to defined icon sizes. Default is true.
     */
    Q_PROPERTY(bool roundToIconSize READ roundToIconSize WRITE setRoundToIconSize NOTIFY roundToIconSizeChanged FINAL)

public:
    enum Status {
        Null = 0, /// No icon has been set
        Ready, /// The icon loaded correctly
        Loading, // The icon is being loaded, but not ready yet
        Error, /// There was an error while loading the icon, for instance a non existent themed name, or an invalid url
    };
    Q_ENUM(Status)

    Icon(QQuickItem *parent = nullptr);
    ~Icon() override;

    void componentComplete() override;

    void setSource(const QVariant &source);
    QVariant source() const;

    void setActive(bool active = true);
    bool active() const;

    bool valid() const;

    void setSelected(bool selected = true);
    bool selected() const;

    void setIsMask(bool mask);
    bool isMask() const;

    void setColor(const QColor &color);
    QColor color() const;

    QString fallback() const;
    void setFallback(const QString &fallback);

    QString placeholder() const;
    void setPlaceholder(const QString &placeholder);

    Status status() const;

    qreal paintedWidth() const;
    qreal paintedHeight() const;

    bool isAnimated() const;
    void setAnimated(bool animated);

    bool roundToIconSize() const;
    void setRoundToIconSize(bool roundToIconSize);

    QSGNode *updatePaintNode(QSGNode *node, UpdatePaintNodeData *data) override;

Q_SIGNALS:
    void sourceChanged();
    void activeChanged();
    void validChanged();
    void selectedChanged();
    void isMaskChanged();
    void colorChanged();
    void fallbackChanged(const QString &fallback);
    void placeholderChanged(const QString &placeholder);
    void statusChanged();
    void paintedAreaChanged();
    void animatedChanged();
    void roundToIconSizeChanged();

protected:
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    QImage findIcon(const QSize &size);
    void handleFinished(QNetworkReply *reply);
    void handleRedirect(QNetworkReply *reply);
    QIcon::Mode iconMode() const;
    bool guessMonochrome(const QImage &img);
    void setStatus(Status status);
    void updatePolish() override;
    void updatePaintedGeometry();
    void updateIsMaskHeuristic(const QString &iconSource);
    void itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value) override;

private:
    void valueChanged(const QVariant &value);
    void windowVisibleChanged(bool visible);
    QSGNode *createSubtree(qreal initialOpacity);
    void updateSubtree(QSGNode *node, qreal opacity);
    QSize iconSizeHint() const;
    inline QImage iconPixmap(const QIcon &icon) const;
    QIcon loadFromTheme(const QString &iconName) const;

    Kirigami::Platform::PlatformTheme *m_theme = nullptr;
    Kirigami::Platform::Units *m_units = nullptr;
    QPointer<QNetworkReply> m_networkReply;
    QHash<int, bool> m_monochromeHeuristics;
    QVariant m_source;
    qreal m_devicePixelRatio = 1.0;
    Status m_status = Null;
    bool m_textureChanged = false;
    bool m_sizeChanged = false;
    bool m_active;
    bool m_selected;
    bool m_isMask;
    bool m_isMaskHeuristic = false;
    QImage m_loadedImage;
    QColor m_color = Qt::transparent;
    QString m_fallback = QStringLiteral("unknown");
    QString m_placeholder = QStringLiteral("image-png");
    QSizeF m_paintedSize;

    QImage m_oldIcon;
    QImage m_icon;

    // animation on image change
    QPropertyAnimation *m_animation = nullptr;
    qreal m_animValue = 1.0;
    bool m_animated = false;
    bool m_roundToIconSize = true;
    bool m_allowNextAnimation = false;
    bool m_blockNextAnimation = false;
    QPointer<QQuickWindow> m_window;
};
