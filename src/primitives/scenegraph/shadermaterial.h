/*
 *  SPDX-FileCopyrightText: 2025 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QColor>
#include <QSGMaterial>
#include <QSGMaterialShader>

/**
 * A material rendering a rectangle with a shadow.
 *
 * This material uses a distance field shader to render a rectangle with a
 * shadow below it, optionally with rounded corners.
 */
class ShaderMaterial : public QSGMaterial
{
public:
    ShaderMaterial(const QString &name);
    ShaderMaterial(QSGMaterialType *type);

    QString name() const;

    QSGMaterialShader *createShader(QSGRendererInterface::RenderMode) const override;
    QSGMaterialType *type() const override;
    int compare(const QSGMaterial *other) const override;

    QList<QPair<QString, QVariant>> uniformData() const;

    bool setUniform(QAnyStringView name, const QVariant &value);

    QSGTexture *texture(int binding);
    void setTexture(int binding, QSGTexture *texture);

    static QString nameForType(QSGMaterialType *type);
    static QSGMaterialType *typeForName(const QString &name);

private:
    QString m_name;
    QSGMaterialType *m_type;

    QList<QPair<QString, QVariant>> m_uniformData;
    QMap<int, QSGTexture *> m_textures;

    inline static QHash<QString, QSGMaterialType *> s_materialTypes;
};

class ShaderMaterialShader : public QSGMaterialShader
{
public:
    ShaderMaterialShader(const QString &shaderName);

    bool updateUniformData(QSGMaterialShader::RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial) override;
    void updateSampledImage(QSGMaterialShader::RenderState &state, //
                            int binding,
                            QSGTexture **texture,
                            QSGMaterial *newMaterial,
                            QSGMaterial *oldMaterial) override;
};
