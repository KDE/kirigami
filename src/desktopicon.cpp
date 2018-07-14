/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *   Copyright 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "desktopicon.h"
#include "libkirigami/platformtheme.h"

#include <QSGSimpleTextureNode>
#include <qquickwindow.h>
#include <QIcon>
#include <QBitmap>
#include <QSGTexture>
#include <QDebug>
#include <QSGSimpleTextureNode>
#include <QSGTexture>
#include <QSharedPointer>
#include <QtQml>
#include <QQuickImageProvider>
#include <QGuiApplication>
#include <QPointer>
#include <QPainter>
#include <QScreen>

QString DesktopIcon::s_internalIconPath = QString();

class ManagedTextureNode : public QSGSimpleTextureNode
{
Q_DISABLE_COPY(ManagedTextureNode)
public:
    ManagedTextureNode();

    void setTexture(QSharedPointer<QSGTexture> texture);

private:
    QSharedPointer<QSGTexture> m_texture;
};

ManagedTextureNode::ManagedTextureNode()
{}

void ManagedTextureNode::setTexture(QSharedPointer<QSGTexture> texture)
{
    m_texture = texture;
    QSGSimpleTextureNode::setTexture(texture.data());
}

typedef QHash<qint64, QHash<QWindow*, QWeakPointer<QSGTexture> > > TexturesCache;

struct ImageTexturesCachePrivate
{
    TexturesCache cache;
};

class ImageTexturesCache
{
public:
    ImageTexturesCache();
    ~ImageTexturesCache();

    /**
     * @returns the texture for a given @p window and @p image.
     *
     * If an @p image id is the same as one already provided before, we won't create
     * a new texture and return a shared pointer to the existing texture.
     */
    QSharedPointer<QSGTexture> loadTexture(QQuickWindow *window, const QImage &image, QQuickWindow::CreateTextureOptions options);

    QSharedPointer<QSGTexture> loadTexture(QQuickWindow *window, const QImage &image);


private:
    QScopedPointer<ImageTexturesCachePrivate> d;
};


ImageTexturesCache::ImageTexturesCache()
    : d(new ImageTexturesCachePrivate)
{
}

ImageTexturesCache::~ImageTexturesCache()
{
}

QSharedPointer<QSGTexture> ImageTexturesCache::loadTexture(QQuickWindow *window, const QImage &image, QQuickWindow::CreateTextureOptions options)
{
    qint64 id = image.cacheKey();
    QSharedPointer<QSGTexture> texture = d->cache.value(id).value(window).toStrongRef();

    if (!texture) {
        auto cleanAndDelete = [this, window, id](QSGTexture* texture) {
            QHash<QWindow*, QWeakPointer<QSGTexture> >& textures = (d->cache)[id];
            textures.remove(window);
            if (textures.isEmpty())
                d->cache.remove(id);
            delete texture;
        };
        texture = QSharedPointer<QSGTexture>(window->createTextureFromImage(image, options), cleanAndDelete);
        (d->cache)[id][window] = texture.toWeakRef();
    }

    //if we have a cache in an atlas but our request cannot use an atlassed texture
    //create a new texture and use that
    //don't use removedFromAtlas() as that requires keeping a reference to the non atlased version
    if (!(options & QQuickWindow::TextureCanUseAtlas) && texture->isAtlasTexture()) {
        texture = QSharedPointer<QSGTexture>(window->createTextureFromImage(image, options));
    }

    return texture;
}

QSharedPointer<QSGTexture> ImageTexturesCache::loadTexture(QQuickWindow *window, const QImage &image)
{
    return loadTexture(window, image, 0);
}

Q_GLOBAL_STATIC(ImageTexturesCache, s_iconImageCache)

DesktopIcon::DesktopIcon(QQuickItem *parent)
    : QQuickItem(parent),
      m_smooth(false),
      m_changed(false),
      m_active(false),
      m_selected(false),
      m_isMask(false)
{
    setFlag(ItemHasContents, true);
    //FIXME: not necessary anymore
    connect(qApp, &QGuiApplication::paletteChanged, this, [this]() {
        m_changed = true;
        update();
    });
}


DesktopIcon::~DesktopIcon()
{
}

void DesktopIcon::setSource(const QVariant &icon)
{
    if (m_source == icon) {
        return;
    }
    m_source = icon;
    m_changed = true;

    if (!m_theme) {
        m_theme = static_cast<Kirigami::PlatformTheme *>(qmlAttachedPropertiesObject<Kirigami::PlatformTheme>(this, true));
        Q_ASSERT(m_theme);

        connect(m_theme, &Kirigami::PlatformTheme::colorsChanged, this, [this]() {
            m_changed = true;
            update();
        });
    }

    if (m_networkReply) {
        //if there was a network query going on, interrupt it
        m_networkReply->close();
    }
    m_loadedImage = QImage();
    update();
    emit sourceChanged();
}

QVariant DesktopIcon::source() const
{
    return m_source;
}

void DesktopIcon::setEnabled(const bool enabled)
{
    if (enabled == QQuickItem::isEnabled()) {
        return;
    }
    QQuickItem::setEnabled(enabled);
    m_changed = true;
    update();
    emit enabledChanged();
}


void DesktopIcon::setActive(const bool active)
{
    if (active == m_active) {
        return;
    }
    m_active = active;
    m_changed = true;
    update();
    emit activeChanged();
}

bool DesktopIcon::active() const
{
    return m_active;
}

bool DesktopIcon::valid() const
{
    return !m_source.isNull();
}

void DesktopIcon::setSelected(const bool selected)
{
    if (selected == m_selected) {
        return;
    }
    m_selected = selected;
    m_changed = true;
    update();
    emit selectedChanged();
}

bool DesktopIcon::selected() const
{
    return m_selected;
}

void DesktopIcon::setIsMask(bool mask)
{
    if (m_isMask == mask) {
        return;
    }

    m_isMask = mask;
    m_changed = true;
    update();
    emit isMaskChanged();
}

bool DesktopIcon::isMask() const
{
    return m_isMask;
}

void DesktopIcon::setColor(const QColor &color)
{
    if (m_color == color) {
        return;
    }

    m_color = color;
    m_changed = true;
    update();
    emit colorChanged();
}

QColor DesktopIcon::color() const
{
    return m_color;
}


int DesktopIcon::implicitWidth() const
{
    return 32;
}

int DesktopIcon::implicitHeight() const
{
    return 32;
}

void DesktopIcon::setSmooth(const bool smooth)
{
    if (smooth == m_smooth) {
        return;
    }
    m_smooth = smooth;
    m_changed = true;
    update();
    emit smoothChanged();
}

bool DesktopIcon::smooth() const
{
    return m_smooth;
}

QSGNode* DesktopIcon::updatePaintNode(QSGNode* node, QQuickItem::UpdatePaintNodeData* /*data*/)
{
    if (m_source.isNull()) {
        delete node;
        return Q_NULLPTR;
    }

    if (m_changed || node == 0) {
        QImage img;
        const QSize itemSize(width(), height());
        QRect nodeRect(QPoint(0,0), itemSize);

        if (itemSize.width() != 0 && itemSize.height() != 0) {
            const auto multiplier = QCoreApplication::instance()->testAttribute(Qt::AA_UseHighDpiPixmaps) ? 1 : (window() ? window()->devicePixelRatio() : qApp->devicePixelRatio());
            const QSize size = itemSize * multiplier;

            switch(m_source.type()){
            case QVariant::Pixmap:
                img = m_source.value<QPixmap>().toImage();
                break;
            case QVariant::Image:
                img = m_source.value<QImage>();
                break;
            case QVariant::Bitmap:
                img = m_source.value<QBitmap>().toImage();
                break;
            case QVariant::Icon:
                img = m_source.value<QIcon>().pixmap(size, iconMode(), QIcon::On).toImage();
                break;
            case QVariant::Url:
            case QVariant::String:
                img = findIcon(size);
                break;
            case QVariant::Brush:
                //todo: fill here too?
            case QVariant::Color:
                img = QImage(size, QImage::Format_Alpha8);
                img.fill(m_source.value<QColor>());
                break;
            default:
                break;
            }

            if (img.isNull()){
                img = QImage(size, QImage::Format_Alpha8);
                img.fill(Qt::transparent);
            }
            if (img.size() != size){
                // At this point, the image will already be scaled, but we need to output it in
                // the correct aspect ratio, painted centered in the viewport. So:
                QRect destination(QPoint(0, 0), img.size().scaled(itemSize, Qt::KeepAspectRatio));
                destination.moveCenter(nodeRect.center());
                nodeRect = destination;
            }
        }
        m_changed = false;

        ManagedTextureNode* mNode = dynamic_cast<ManagedTextureNode*>(node);
        if (!mNode) {
            delete node;
            mNode = new ManagedTextureNode;
        }
        mNode->setTexture(s_iconImageCache->loadTexture(window(), img));
        mNode->setRect(nodeRect);
        node = mNode;
        if (m_smooth) {
            mNode->setFiltering(QSGTexture::Linear);
        }
    }

    return node;
}

void DesktopIcon::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    if (newGeometry.size() != oldGeometry.size()) {
        m_changed = true;
        update();
    }
    QQuickItem::geometryChanged(newGeometry, oldGeometry);
}

void DesktopIcon::handleFinished(QNetworkAccessManager* qnam, QNetworkReply* reply) {
    if (reply && reply->error() == QNetworkReply::NoError) {
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
            connect(m_networkReply.data(), &QNetworkReply::readyRead, this, [this](){handleReadyRead(m_networkReply); });
            connect(m_networkReply.data(), &QNetworkReply::finished, this, [this, qnam](){handleFinished(qnam, m_networkReply); });
            return;
        }
    }
}

void DesktopIcon::handleReadyRead(QNetworkReply* reply)
{
    if (reply && reply->attribute(QNetworkRequest::RedirectionTargetAttribute).isNull()) {
        // We're handing the event loop back while doing network work, and it turns out
        // this fairly regularly results in things being deleted under us. So, just
        // handle that and crash less :)
        QPointer<DesktopIcon> me(this);
        QPointer<QNetworkReply> guardedReply(reply);
        QByteArray data;
        do {
            data.append(guardedReply->read(32768));
            // Because we are in the main thread, this could be potentially very expensive, so let's not block
            qApp->processEvents();
            if(!me || !guardedReply) {
                return;
            }
        } while(!guardedReply->atEnd());
        m_loadedImage = QImage::fromData(data);
        if (m_loadedImage.isNull()) {
            // broken image from data, inform the user of this with some useful broken-image thing...
            const QSize size = QSize(width(), height()) * (window() ? window()->devicePixelRatio() : qApp->devicePixelRatio());
            m_loadedImage = QIcon::fromTheme("unknown").pixmap(size, iconMode(), QIcon::On).toImage();
        }
        m_changed = true;
        update();
    }
}

QImage DesktopIcon::findIcon(const QSize &size)
{
    QImage img;
    QString iconSource = m_source.toString();

    if (iconSource.startsWith("image://")){
        QUrl iconUrl(iconSource);
        QString iconProviderId = iconUrl.host();
        QString iconId = iconUrl.path();
        QSize actualSize;
        QQuickImageProvider* imageProvider = dynamic_cast<QQuickImageProvider*>(
                    qmlEngine(this)->imageProvider(iconProviderId));
        if (!imageProvider)
            return img;
        switch(imageProvider->imageType()){
        case QQmlImageProviderBase::Image:
            img = imageProvider->requestImage(iconId, &actualSize, size);
            break;
        case QQmlImageProviderBase::Pixmap:
            img = imageProvider->requestPixmap(iconId, &actualSize, size).toImage();
            break;
        case QQmlImageProviderBase::Texture:
        case QQmlImageProviderBase::Invalid:
        case QQmlImageProviderBase::ImageResponse:
            //will have to investigate this more
            break;
        }
    } else if(iconSource.startsWith("http://") || iconSource.startsWith("https://")) {
        if(!m_loadedImage.isNull()) {
            return m_loadedImage.scaled(size, Qt::KeepAspectRatio, m_smooth ? Qt::SmoothTransformation : Qt::FastTransformation );
        }
        QQmlEngine* engine = qmlEngine(this);
        QNetworkAccessManager* qnam;
        if (engine && (qnam = qmlEngine(this)->networkAccessManager())) {
            QNetworkRequest request(m_source.toUrl());
            request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
            m_networkReply = qnam->get(request);
            connect(m_networkReply.data(), &QNetworkReply::readyRead, this, [this](){ handleReadyRead(m_networkReply); });
            connect(m_networkReply.data(), &QNetworkReply::finished, this, [this, qnam](){ handleFinished(qnam, m_networkReply); });
        }
        // Temporary icon while we wait for the real image to load...
        img = QIcon::fromTheme("image-x-icon").pixmap(size, iconMode(), QIcon::On).toImage();
    } else {
        if (iconSource.startsWith("qrc:/")){
            iconSource = iconSource.mid(3);
        }
        QIcon icon;
        const QColor tintColor = m_color == Qt::transparent ? (m_selected ? m_theme->highlightedTextColor() : m_theme->textColor()) : m_color;
        const bool isPath = iconSource.contains("/");
        if (isPath) {
            icon = QIcon(iconSource);
        } else {
            if (icon.isNull()) {
                QQmlContext *ctx = QQmlEngine::contextForObject(this);
                if (ctx) {
                    const QString localIconSource = s_internalIconPath % "/" % iconSource % ".svg";
                    if (QFile::exists(localIconSource)) {
                        icon = QIcon(localIconSource);
                    }
                    //heuristic to set every icon as mask, maybe only android?
                    if (!icon.isNull()) {
                        icon.setIsMask(true);
                    }
                }
            }
            if (icon.isNull()) {
                icon = m_theme->iconFromTheme(iconSource, tintColor);
            }
        }
        if (!icon.isNull()) {
            img = icon.pixmap(size, iconMode(), QIcon::On).toImage();
            qreal ratio = 1;
            if (window() && window()->screen()) {
                ratio = window()->screen()->devicePixelRatio();
            }
            if (m_color != Qt::transparent && (m_isMask ||
                //this is an heuristic to decide when to tint and when to just draw
                //(fullcolor icons) in reality on basic styles the only colored icons should be -symbolic, this heuristic is the most compatible middle ground
                //48 is the usual value for "big" icons (enum we can't access from here) which we need to take dpis into account
                (icon.isMask() && (iconSource.endsWith("-symbolic") || size.width() < 48.0 * ratio)) ||
                (isPath && tintColor != Qt::transparent))) {
                QPainter p(&img);
                p.setCompositionMode(QPainter::CompositionMode_SourceIn);
                p.fillRect(img.rect(), tintColor);
                p.end();
            }
        }
    }
    return img;
}

QIcon::Mode DesktopIcon::iconMode() const
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
