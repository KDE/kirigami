/*
 *  SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include <QSGTexture>

class TextureCache
{
public:
    TextureCache()
    {
    }

    /**
     * @returns the texture for a given @p window and @p image.
     *
     * If an @p image id is the same as one already provided before, we won't create
     * a new texture and return a shared pointer to the existing texture.
     */
    static std::shared_ptr<QSGTexture> loadTexture(QQuickWindow *window, const QImage &image, QQuickWindow::CreateTextureOptions options);
    static std::shared_ptr<QSGTexture> loadTexture(QQuickWindow *window, const QImage &image);

private:
    inline static QHash<QPair<qint64, QWindow *>, std::weak_ptr<QSGTexture>> s_cache;
};
