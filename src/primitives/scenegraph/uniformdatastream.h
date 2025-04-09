/*
 *  SPDX-FileCopyrightText: 2025 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QSGMaterialShader>
#include <QVariant>

/*!
 * A helper that simplifies writing uniform data for QSGMaterialShader.
 */
struct UniformDataStream {
    inline UniformDataStream(std::span<char> data) noexcept
        : bytes(data.data())
        , remainingSize(data.size())
    {
    }

    ~UniformDataStream()
    {
    }

    template<typename Data>
    inline void skip(const Data &data = {})
    {
        constexpr int dataSize = sizeof(Data);
        align(dataSize);
        Q_UNUSED(data);

        Q_ASSERT(remainingSize - dataSize >= 0);

        bytes += dataSize;
        offset += dataSize;
        remainingSize -= dataSize;
    }

    inline void skipComponents(int count)
    {
        const int skipCount = count * 4;
        align(4);

        Q_ASSERT(remainingSize - skipCount >= 0);

        bytes += skipCount;
        offset += skipCount;
        remainingSize -= skipCount;
    }

    inline void skipMatrixOpacity()
    {
        align(Matrix4x4Size);
        Q_ASSERT(remainingSize - Matrix4x4Size >= 0);
        bytes += Matrix4x4Size;
        offset += Matrix4x4Size;
        remainingSize -= Matrix4x4Size;

        align(FloatSize);
        Q_ASSERT(remainingSize - FloatSize >= 0);
        bytes += FloatSize;
        offset += FloatSize;
        remainingSize -= FloatSize;
    }

    template<typename Data>
    friend inline UniformDataStream &operator<<(UniformDataStream &stream, const Data &data)
    {
        constexpr uint dataSize = sizeof(Data);
        stream.align(dataSize);

        Q_ASSERT(stream.remainingSize - dataSize >= 0);

        memcpy(stream.bytes, &data, dataSize);

        stream.bytes += dataSize;
        stream.offset += dataSize;
        stream.remainingSize -= dataSize;

        return stream;
    }

    friend inline UniformDataStream &operator<<(UniformDataStream &stream, const QMatrix4x4 &m)
    {
        stream.align(Matrix4x4Size);

        Q_ASSERT(stream.remainingSize - Matrix4x4Size >= 0);

        memcpy(stream.bytes, m.constData(), Matrix4x4Size);
        stream.bytes += Matrix4x4Size;
        stream.offset += Matrix4x4Size;
        stream.remainingSize -= Matrix4x4Size;

        return stream;
    }

    friend inline UniformDataStream &operator<<(UniformDataStream &stream, const QColor &color)
    {
        stream.align(ColorSize);

        Q_ASSERT(stream.remainingSize - ColorSize >= 0);

        std::array<float, 4> colorArray;
        color.getRgbF(&colorArray[0], &colorArray[1], &colorArray[2], &colorArray[3]);
        memcpy(stream.bytes, colorArray.data(), ColorSize);

        stream.bytes += ColorSize;
        stream.offset += ColorSize;
        stream.remainingSize -= ColorSize;

        return stream;
    }

    template<typename T>
    friend inline UniformDataStream &operator<<(UniformDataStream &stream, const QList<T> &v)
    {
        for (const auto &item : v) {
            stream << item;
            // Using std140, array elements are padded to a size of 16 bytes per element.
            stream.align(16);
        }
        return stream;
    }

    char *bytes;
    int remainingSize;
    int padding = 16;
    int offset = 0;

private:
    static constexpr int FloatSize = sizeof(float);
    static constexpr int ColorSize = FloatSize * 4;
    static constexpr int Matrix4x4Size = FloatSize * 4 * 4;

    // Encode alignment rules for std140.
    // Minimum alignment is 4 bytes.
    // Vec2 alignment is 8 bytes.
    // Vec3 and Vec4 alignment is 16 bytes.
    inline void align(uint size)
    {
        if (size <= 4) {
            const auto padding = offset % 4 > 0 ? 4 - offset % 4 : 0;

            Q_ASSERT(remainingSize - padding >= 0);

            offset += padding;
            bytes += padding;
            remainingSize -= padding;
        } else if (size <= 8) {
            auto padding = offset % 8 > 0 ? 8 - offset % 8 : 0;

            Q_ASSERT(remainingSize - padding >= 0);

            offset += padding;
            bytes += padding;
            remainingSize -= padding;
        } else {
            auto padding = offset % 16 > 0 ? 16 - offset % 16 : 0;

            Q_ASSERT(remainingSize - padding >= 0);

            offset += padding;
            bytes += padding;
            remainingSize -= padding;
        }
    }
};
