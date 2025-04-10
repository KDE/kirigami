/*
 *  SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "texturecache.h"

#include <QImage>

std::shared_ptr<QSGTexture> TextureCache::loadTexture(QQuickWindow *window, const QImage &image, QQuickWindow::CreateTextureOptions options)
{
    if (image.isNull()) {
        return nullptr;
    }

    auto id = qMakePair(image.cacheKey(), window);
    std::shared_ptr<QSGTexture> texture = s_cache.value(id).lock();

    if (!texture) {
        auto cleanAndDelete = [id](QSGTexture *texture) {
            s_cache.remove(id);
            delete texture;
        };
        texture = std::shared_ptr<QSGTexture>(window->createTextureFromImage(image, options), cleanAndDelete);
        s_cache[id] = texture;
    }

    // if we have a cache in an atlas but our request cannot use an atlassed texture
    // create a new texture and use that
    // don't use removedFromAtlas() as that requires keeping a reference to the non atlased version
    if (!(options & QQuickWindow::TextureCanUseAtlas) && texture->isAtlasTexture()) {
        texture = std::shared_ptr<QSGTexture>(window->createTextureFromImage(image, options));
    }

    return texture;
}

std::shared_ptr<QSGTexture> TextureCache::loadTexture(QQuickWindow *window, const QImage &image)
{
    return loadTexture(window, image, {});
}
