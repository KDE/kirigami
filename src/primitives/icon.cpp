/*
 *  SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "icon.h"
#include "scenegraph/managedtexturenode.h"

#include "platform/platformtheme.h"
#include "platform/units.h"

#include <QBitmap>
#include <QDebug>
#include <QGuiApplication>
#include <QIcon>
#include <QNetworkReply>
#include <QPainter>
#include <QPropertyAnimation>
#include <QQuickImageProvider>
#include <QQuickWindow>
#include <QSGSimpleTextureNode>
#include <QSGTexture>
#include <QScreen>
#include <cstdlib>

Q_GLOBAL_STATIC(ImageTexturesCache, s_iconImageCache)

Icon::Icon(QQuickItem *parent)
    : QQuickItem(parent)
    , m_active(false)
    , m_selected(false)
    , m_isMask(false)
{
    setFlag(ItemHasContents, true);
    // Using 32 because Icon used to redefine implicitWidth and implicitHeight and hardcode them to 32
    setImplicitSize(32, 32);

    connect(this, &QQuickItem::smoothChanged, this, &QQuickItem::polish);
    connect(this, &QQuickItem::enabledChanged, this, [this]() {
        polish();
    });
}

Icon::~Icon()
{
}

void Icon::componentComplete()
{
    QQuickItem::componentComplete();

    QQmlEngine *engine = qmlEngine(this);
    Q_ASSERT(engine);
    m_units = engine->singletonInstance<Kirigami::Platform::Units *>("org.kde.kirigami.platform", "Units");
    Q_ASSERT(m_units);
    m_animation = new QPropertyAnimation(this);
    connect(m_animation, &QPropertyAnimation::valueChanged, this, &Icon::valueChanged);
    connect(m_animation, &QPropertyAnimation::finished, this, [this]() {
        m_oldIcon = QImage();
        m_textureChanged = true;
        update();
    });
    m_animation->setTargetObject(this);
    m_animation->setEasingCurve(QEasingCurve::InOutCubic);
    m_animation->setDuration(m_units->longDuration());
    connect(m_units, &Kirigami::Platform::Units::longDurationChanged, m_animation, [this]() {
        m_animation->setDuration(m_units->longDuration());
    });
    updatePaintedGeometry();
}

void Icon::setSource(const QVariant &icon)
{
    if (m_source == icon) {
        return;
    }
    m_source = icon;

    if (!m_theme) {
        m_theme = static_cast<Kirigami::Platform::PlatformTheme *>(qmlAttachedPropertiesObject<Kirigami::Platform::PlatformTheme>(this, true));
        Q_ASSERT(m_theme);

        connect(m_theme, &Kirigami::Platform::PlatformTheme::colorsChanged, this, &QQuickItem::polish);
    }

    if (m_networkReply) {
        // if there was a network query going on, interrupt it
        m_networkReply->close();
    }
    m_loadedImage = QImage();
    setStatus(Loading);

    polish();
    Q_EMIT sourceChanged();
    Q_EMIT validChanged();
}

QVariant Icon::source() const
{
    return m_source;
}

void Icon::setActive(const bool active)
{
    if (active == m_active) {
        return;
    }
    m_active = active;
    polish();
    Q_EMIT activeChanged();
}

bool Icon::active() const
{
    return m_active;
}

bool Icon::valid() const
{
    // TODO: should this be return m_status == Ready?
    // Consider an empty URL invalid, even though isNull() will say false
    if (m_source.canConvert<QUrl>() && m_source.toUrl().isEmpty()) {
        return false;
    }

    return !m_source.isNull();
}

void Icon::setSelected(const bool selected)
{
    if (selected == m_selected) {
        return;
    }
    m_selected = selected;
    polish();
    Q_EMIT selectedChanged();
}

bool Icon::selected() const
{
    return m_selected;
}

void Icon::setIsMask(bool mask)
{
    if (m_isMask == mask) {
        return;
    }

    m_isMask = mask;
    polish();
    Q_EMIT isMaskChanged();
}

bool Icon::isMask() const
{
    return m_isMask;
}

void Icon::setColor(const QColor &color)
{
    if (m_color == color) {
        return;
    }

    m_color = color;
    polish();
    Q_EMIT colorChanged();
}

QColor Icon::color() const
{
    return m_color;
}

QSGNode *Icon::createSubtree(qreal initialOpacity)
{
    auto opacityNode = new QSGOpacityNode{};
    opacityNode->setFlag(QSGNode::OwnedByParent, true);
    opacityNode->setOpacity(initialOpacity);

    auto *mNode = new ManagedTextureNode;

    mNode->setTexture(s_iconImageCache->loadTexture(window(), m_icon, QQuickWindow::TextureCanUseAtlas));

    opacityNode->appendChildNode(mNode);

    return opacityNode;
}

void Icon::updateSubtree(QSGNode *node, qreal opacity)
{
    auto opacityNode = static_cast<QSGOpacityNode *>(node);
    opacityNode->setOpacity(opacity);

    auto textureNode = static_cast<ManagedTextureNode *>(opacityNode->firstChild());
    textureNode->setFiltering(smooth() ? QSGTexture::Linear : QSGTexture::Nearest);
}

QSGNode *Icon::updatePaintNode(QSGNode *node, QQuickItem::UpdatePaintNodeData * /*data*/)
{
    if (m_source.isNull() || qFuzzyIsNull(width()) || qFuzzyIsNull(height())) {
        delete node;
        return nullptr;
    }

    if (!node) {
        node = new QSGNode{};
    }

    if (m_animation && m_animation->state() == QAbstractAnimation::Running) {
        if (node->childCount() < 2) {
            node->appendChildNode(createSubtree(0.0));
            m_textureChanged = true;
        }

        // Rather than doing a perfect crossfade, first fade in the new texture
        // then fade out the old texture. This is done to avoid the underlying
        // color bleeding through when both textures are at ~0.5 opacity, which
        // causes flickering if the two textures are very similar.
        updateSubtree(node->firstChild(), 2.0 - m_animValue * 2.0);
        updateSubtree(node->lastChild(), m_animValue * 2.0);
    } else {
        if (node->childCount() == 0) {
            node->appendChildNode(createSubtree(1.0));
            m_textureChanged = true;
        }

        if (node->childCount() > 1) {
            auto toRemove = node->firstChild();
            node->removeChildNode(toRemove);
            delete toRemove;
        }

        updateSubtree(node->firstChild(), 1.0);
    }

    if (m_textureChanged) {
        auto mNode = static_cast<ManagedTextureNode *>(node->lastChild()->firstChild());
        mNode->setTexture(s_iconImageCache->loadTexture(window(), m_icon, QQuickWindow::TextureCanUseAtlas));
        m_textureChanged = false;
        m_sizeChanged = true;
    }

    if (m_sizeChanged) {
        const QSizeF iconPixSize(m_icon.width() / m_devicePixelRatio, m_icon.height() / m_devicePixelRatio);
        const QSizeF itemPixSize = QSizeF((size() * m_devicePixelRatio).toSize()) / m_devicePixelRatio;
        QRectF nodeRect(QPoint(0, 0), itemPixSize);

        if (itemPixSize.width() != 0 && itemPixSize.height() != 0) {
            if (iconPixSize != itemPixSize) {
                // At this point, the image will already be scaled, but we need to output it in
                // the correct aspect ratio, painted centered in the viewport. So:
                QRectF destination(QPointF(0, 0), QSizeF(m_icon.size()).scaled(m_paintedSize, Qt::KeepAspectRatio));
                destination.moveCenter(nodeRect.center());
                destination.moveTopLeft(QPointF(destination.topLeft().toPoint() * m_devicePixelRatio) / m_devicePixelRatio);
                nodeRect = destination;
            }
        }

        // Adjust the final node on the pixel grid
        QPointF globalPixelPos = mapToScene(nodeRect.topLeft()) * m_devicePixelRatio;
        QPointF posAdjust = QPointF(globalPixelPos.x() - std::round(globalPixelPos.x()), globalPixelPos.y() - std::round(globalPixelPos.y()));
        nodeRect.moveTopLeft(nodeRect.topLeft() - posAdjust);

        for (int i = 0; i < node->childCount(); ++i) {
            auto mNode = static_cast<ManagedTextureNode *>(node->childAtIndex(i)->firstChild());
            mNode->setRect(nodeRect);
        }

        m_sizeChanged = false;
    }

    return node;
}

void Icon::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickItem::geometryChange(newGeometry, oldGeometry);
    if (newGeometry.size() != oldGeometry.size()) {
        m_sizeChanged = true;
        updatePaintedGeometry();
        polish();
    }
}

void Icon::handleRedirect(QNetworkReply *reply)
{
    QNetworkAccessManager *qnam = reply->manager();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }
    const QUrl possibleRedirectUrl = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
    if (!possibleRedirectUrl.isEmpty()) {
        const QUrl redirectUrl = reply->url().resolved(possibleRedirectUrl);
        if (redirectUrl == reply->url()) {
            // no infinite redirections thank you very much
            reply->deleteLater();
            return;
        }
        reply->deleteLater();
        QNetworkRequest request(possibleRedirectUrl);
        request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
        m_networkReply = qnam->get(request);
        connect(m_networkReply.data(), &QNetworkReply::finished, this, [this]() {
            handleFinished(m_networkReply);
        });
    }
}

void Icon::handleFinished(QNetworkReply *reply)
{
    if (!reply) {
        return;
    }

    reply->deleteLater();
    if (!reply->attribute(QNetworkRequest::RedirectionTargetAttribute).isNull()) {
        handleRedirect(reply);
        return;
    }

    m_loadedImage = QImage();

    const QString filename = reply->url().fileName();
    if (!m_loadedImage.load(reply, filename.mid(filename.indexOf(QLatin1Char('.'))).toLatin1().constData())) {
        // broken image from data, inform the user of this with some useful broken-image thing...
        m_loadedImage = iconPixmap(QIcon::fromTheme(m_fallback));
    }

    polish();
}

void Icon::updatePolish()
{
    QQuickItem::updatePolish();

    if (window()) {
        m_devicePixelRatio = window()->effectiveDevicePixelRatio();
    }

    if (m_source.isNull()) {
        setStatus(Ready);
        updatePaintedGeometry();
        update();
        return;
    }

    const QSize itemSize(width(), height());
    if (itemSize.width() != 0 && itemSize.height() != 0) {
        const QSize size = itemSize;

        if (m_animation) {
            m_animation->stop();
            m_oldIcon = m_icon;
        }

        switch (m_source.userType()) {
        case QMetaType::QPixmap:
            m_icon = m_source.value<QPixmap>().toImage();
            break;
        case QMetaType::QImage:
            m_icon = m_source.value<QImage>();
            break;
        case QMetaType::QBitmap:
            m_icon = m_source.value<QBitmap>().toImage();
            break;
        case QMetaType::QIcon: {
            m_icon = iconPixmap(m_source.value<QIcon>());
            break;
        }
        case QMetaType::QUrl:
        case QMetaType::QString:
            m_icon = findIcon(size);
            break;
        case QMetaType::QBrush:
            // todo: fill here too?
        case QMetaType::QColor:
            m_icon = QImage(size, QImage::Format_Alpha8);
            m_icon.fill(m_source.value<QColor>());
            break;
        default:
            break;
        }

        if (m_icon.isNull()) {
            m_icon = QImage(size, QImage::Format_Alpha8);
            m_icon.fill(Qt::transparent);
        }

        const QColor tintColor = //
            !m_color.isValid() || m_color == Qt::transparent //
            ? (m_selected ? m_theme->highlightedTextColor() : m_theme->textColor())
            : m_color;

        // TODO: initialize m_isMask with icon.isMask()
        if (tintColor.alpha() > 0 && isMask()) {
            QPainter p(&m_icon);
            p.setCompositionMode(QPainter::CompositionMode_SourceIn);
            p.fillRect(m_icon.rect(), tintColor);
            p.end();
        }
    }

    // don't animate initial setting
    bool animated = m_animated && !m_oldIcon.isNull() && !m_sizeChanged && !m_blockNextAnimation;

    if (animated && m_animation) {
        m_animValue = 0.0;
        m_animation->setStartValue((qreal)0);
        m_animation->setEndValue((qreal)1);
        m_animation->start();
    } else {
        if (m_animation) {
            m_animation->stop();
        }
        m_animValue = 1.0;
        m_blockNextAnimation = false;
    }
    m_textureChanged = true;
    updatePaintedGeometry();
    update();
}

QImage Icon::findIcon(const QSize &size)
{
    QImage img;
    QString iconSource = m_source.toString();

    if (iconSource.startsWith(QLatin1String("image://"))) {
        QUrl iconUrl(iconSource);
        QString iconProviderId = iconUrl.host();
        // QUrl path has the  "/" prefix while iconId does not
        QString iconId = iconUrl.path().remove(0, 1);

        QSize actualSize;
        auto engine = qmlEngine(this);
        if (!engine) {
            return img;
        }
        QQuickImageProvider *imageProvider = dynamic_cast<QQuickImageProvider *>(engine->imageProvider(iconProviderId));
        if (!imageProvider) {
            return img;
        }
        switch (imageProvider->imageType()) {
        case QQmlImageProviderBase::Image:
            img = imageProvider->requestImage(iconId, &actualSize, size);
            if (!img.isNull()) {
                setStatus(Ready);
            }
            break;
        case QQmlImageProviderBase::Pixmap:
            img = imageProvider->requestPixmap(iconId, &actualSize, size).toImage();
            if (!img.isNull()) {
                setStatus(Ready);
            }
            break;
        case QQmlImageProviderBase::ImageResponse: {
            if (!m_loadedImage.isNull()) {
                setStatus(Ready);
                return m_loadedImage.scaled(size, Qt::KeepAspectRatio, smooth() ? Qt::SmoothTransformation : Qt::FastTransformation);
            }
            QQuickAsyncImageProvider *provider = dynamic_cast<QQuickAsyncImageProvider *>(imageProvider);
            auto response = provider->requestImageResponse(iconId, size);
            connect(response, &QQuickImageResponse::finished, this, [iconId, response, this]() {
                if (response->errorString().isEmpty()) {
                    QQuickTextureFactory *textureFactory = response->textureFactory();
                    if (textureFactory) {
                        m_loadedImage = textureFactory->image();
                        delete textureFactory;
                    }
                    if (m_loadedImage.isNull()) {
                        // broken image from data, inform the user of this with some useful broken-image thing...
                        m_loadedImage = iconPixmap(QIcon::fromTheme(m_fallback));
                        setStatus(Error);
                    } else {
                        setStatus(Ready);
                    }
                    polish();
                }
                response->deleteLater();
            });
            // Temporary icon while we wait for the real image to load...
            img = iconPixmap(QIcon::fromTheme(m_placeholder));
            break;
        }
        case QQmlImageProviderBase::Texture: {
            QQuickTextureFactory *textureFactory = imageProvider->requestTexture(iconId, &actualSize, size);
            if (textureFactory) {
                img = textureFactory->image();
            }
            if (img.isNull()) {
                // broken image from data, or the texture factory wasn't healthy, inform the user of this with some useful broken-image thing...
                img = iconPixmap(QIcon::fromTheme(m_fallback));
                setStatus(Error);
            } else {
                setStatus(Ready);
            }
            break;
        }
        case QQmlImageProviderBase::Invalid:
            // will have to investigate this more
            setStatus(Error);
            break;
        }
    } else if (iconSource.startsWith(QLatin1String("http://")) || iconSource.startsWith(QLatin1String("https://"))) {
        if (!m_loadedImage.isNull()) {
            setStatus(Ready);
            return m_loadedImage.scaled(size, Qt::KeepAspectRatio, smooth() ? Qt::SmoothTransformation : Qt::FastTransformation);
        }
        const auto url = m_source.toUrl();
        QQmlEngine *engine = qmlEngine(this);
        QNetworkAccessManager *qnam;
        if (engine && (qnam = engine->networkAccessManager()) && (!m_networkReply || m_networkReply->url() != url)) {
            QNetworkRequest request(url);
            request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
            m_networkReply = qnam->get(request);
            connect(m_networkReply.data(), &QNetworkReply::finished, this, [this]() {
                handleFinished(m_networkReply);
            });
        }
        // Temporary icon while we wait for the real image to load...
        img = iconPixmap(QIcon::fromTheme(m_placeholder));
    } else {
        if (iconSource.startsWith(QLatin1String("qrc:/"))) {
            iconSource = iconSource.mid(3);
        } else if (iconSource.startsWith(QLatin1String("file:/"))) {
            iconSource = QUrl(iconSource).path();
        }

        const QIcon icon = loadFromTheme(iconSource);

        if (!icon.isNull()) {
            img = iconPixmap(icon);
            setStatus(Ready);
        }
    }

    if (!iconSource.isEmpty() && img.isNull()) {
        setStatus(Error);
        img = iconPixmap(QIcon::fromTheme(m_fallback));
    }
    return img;
}

QIcon::Mode Icon::iconMode() const
{
    if (!isEnabled()) {
        return QIcon::Disabled;
    } else if (m_selected) {
        return QIcon::Selected;
    } else if (m_active) {
        return QIcon::Active;
    }
    return QIcon::Normal;
}

QString Icon::fallback() const
{
    return m_fallback;
}

void Icon::setFallback(const QString &fallback)
{
    if (m_fallback != fallback) {
        m_fallback = fallback;
        Q_EMIT fallbackChanged(fallback);
    }
}

QString Icon::placeholder() const
{
    return m_placeholder;
}

void Icon::setPlaceholder(const QString &placeholder)
{
    if (m_placeholder != placeholder) {
        m_placeholder = placeholder;
        Q_EMIT placeholderChanged(placeholder);
    }
}

void Icon::setStatus(Status status)
{
    if (status == m_status) {
        return;
    }

    m_status = status;
    Q_EMIT statusChanged();
}

Icon::Status Icon::status() const
{
    return m_status;
}

qreal Icon::paintedWidth() const
{
    return std::round(m_paintedSize.width());
}

qreal Icon::paintedHeight() const
{
    return std::round(m_paintedSize.height());
}

QSize Icon::iconSizeHint() const
{
    if (!m_roundToIconSize) {
        return QSize(width(), height());
    } else if (m_units) {
        return QSize(m_units->iconSizes()->roundedIconSize(std::min(width(), height())), m_units->iconSizes()->roundedIconSize(std::min(width(), height())));
    } else {
        return QSize(std::min(width(), height()), std::min(width(), height()));
    }
}

QImage Icon::iconPixmap(const QIcon &icon) const
{
    const QSize actualSize = icon.actualSize(iconSizeHint());
    QIcon sourceIcon = icon;

    // if we have a non-default theme we need to load the icon with
    // the right colors
    const QQmlEngine *engine = qmlEngine(this);
    if (engine && !engine->property("_kirigamiTheme").toString().isEmpty()) {
        const QString iconName = icon.name();
        if (!iconName.isEmpty() && QIcon::hasThemeIcon(iconName)) {
            sourceIcon = loadFromTheme(iconName);
        }
    }

    return sourceIcon.pixmap(actualSize, m_devicePixelRatio, iconMode(), QIcon::On).toImage();
}

QIcon Icon::loadFromTheme(const QString &iconName) const
{
    const QColor tintColor = !m_color.isValid() || m_color == Qt::transparent ? (m_selected ? m_theme->highlightedTextColor() : m_theme->textColor()) : m_color;
    return m_theme->iconFromTheme(iconName, tintColor);
}

void Icon::updatePaintedGeometry()
{
    QSizeF newSize;
    if (!m_icon.width() || !m_icon.height()) {
        newSize = {0, 0};
    } else {
        qreal roundedWidth = m_units ? m_units->iconSizes()->roundedIconSize(std::min(width(), height())) : 32;
        roundedWidth = std::round(roundedWidth * m_devicePixelRatio) / m_devicePixelRatio;

        if (QSizeF roundedSize(roundedWidth, roundedWidth); size() == roundedSize) {
            m_paintedSize = roundedSize;
            m_textureChanged = true;
            update();
            Q_EMIT paintedAreaChanged();
            return;
        }
        if (m_roundToIconSize && m_units) {
            if (m_icon.width() > m_icon.height()) {
                newSize = QSizeF(roundedWidth, m_icon.height() * (roundedWidth / static_cast<qreal>(m_icon.width())));
            } else {
                newSize = QSizeF(roundedWidth, roundedWidth);
            }
        } else {
            const QSizeF iconPixSize(m_icon.width() / m_devicePixelRatio, m_icon.height() / m_devicePixelRatio);

            const qreal w = widthValid() ? width() : iconPixSize.width();
            const qreal widthScale = w / iconPixSize.width();
            const qreal h = heightValid() ? height() : iconPixSize.height();
            const qreal heightScale = h / iconPixSize.height();

            if (widthScale <= heightScale) {
                newSize = QSizeF(w, widthScale * iconPixSize.height());
            } else if (heightScale < widthScale) {
                newSize = QSizeF(heightScale * iconPixSize.width(), h);
            }
        }
    }
    if (newSize != m_paintedSize) {
        m_paintedSize = newSize;
        m_textureChanged = true;
        update();
        Q_EMIT paintedAreaChanged();
    }
}

bool Icon::isAnimated() const
{
    return m_animated;
}

void Icon::setAnimated(bool animated)
{
    if (m_animated == animated) {
        return;
    }

    m_animated = animated;
    Q_EMIT animatedChanged();
}

bool Icon::roundToIconSize() const
{
    return m_roundToIconSize;
}

void Icon::setRoundToIconSize(bool roundToIconSize)
{
    if (m_roundToIconSize == roundToIconSize) {
        return;
    }

    const QSizeF oldPaintedSize = m_paintedSize;

    m_roundToIconSize = roundToIconSize;
    Q_EMIT roundToIconSizeChanged();

    updatePaintedGeometry();
    if (oldPaintedSize != m_paintedSize) {
        Q_EMIT paintedAreaChanged();
        m_textureChanged = true;
        update();
    }
}

void Icon::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value)
{
    if (change == QQuickItem::ItemDevicePixelRatioHasChanged) {
        m_blockNextAnimation = true;
        if (window()) {
            m_devicePixelRatio = window()->effectiveDevicePixelRatio();
        }
        polish();
    } else if (change == QQuickItem::ItemSceneChange) {
        if (m_window) {
            disconnect(m_window.data(), &QWindow::visibleChanged, this, &Icon::windowVisibleChanged);
        }
        m_window = value.window;
        if (m_window) {
            connect(m_window.data(), &QWindow::visibleChanged, this, &Icon::windowVisibleChanged);
            m_devicePixelRatio = m_window->effectiveDevicePixelRatio();
        }
    } else if (change == ItemVisibleHasChanged && value.boolValue) {
        m_blockNextAnimation = true;
    }
    QQuickItem::itemChange(change, value);
}

void Icon::valueChanged(const QVariant &value)
{
    m_animValue = value.toReal();
    update();
}

void Icon::windowVisibleChanged(bool visible)
{
    if (visible) {
        m_blockNextAnimation = true;
    }
}

#include "moc_icon.cpp"
