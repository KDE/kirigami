/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QColor>
#include <QJSValue>
#include <QObject>
#include <QQuickItem>

#include "kirigamiplatform_export.h"

/*!
 * \qmltype ColorUtils
 * \inqmlmodule org.kde.kirigami.platform
 *
 * \brief Utilities for processing items to obtain colors and information useful for
 * UIs that need to adjust to variable elements.
 */
class KIRIGAMIPLATFORM_EXPORT ColorUtils : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    /*!
     * \enum ColorUtils::Brightness
     *
     * Describes the contrast of an item.
     *
     * \value Dark The item is dark and requires a light foreground color to achieve readable contrast
     * \value Light The item is light and requires a dark foreground color to achieve readable contrast
     *
     */
    enum Brightness {
        Dark,
        Light,
    };
    Q_ENUM(Brightness)

    explicit ColorUtils(QObject *parent = nullptr);

    /*!
     * \qmlmethod enumeration ColorUtils::brightnessForColor(color color)
     *
     * Returns whether a color is bright or dark.
     *
     * \qml
     * import QtQuick
     * import org.kde.kirigami as Kirigami
     *
     * Kirigami.Heading {
     *     text: {
     *         if (Kirigami.ColorUtils.brightnessForColor("pink") == Kirigami.ColorUtils.Light) {
     *             return "The color is light"
     *         } else {
     *             return "The color is dark"
     *         }
     *     }
     * }
     * \endqml
     *
     * \since 5.69
     */
    Q_INVOKABLE ColorUtils::Brightness brightnessForColor(const QColor &color);

    /*!
     * \qmlmethod real ColorUtils::grayForColor(color color)
     *
     * Same Algorithm as brightnessForColor but returns a 0 to 1 value for an
     * estimate of the equivalent gray light value (luma).
     * 0 as full black, 1 as full white and 0.5 equivalent to a 50% gray.
     *
     * \since 5.81
     */
    Q_INVOKABLE qreal grayForColor(const QColor &color);

    /*!
     * \qmlmethod color ColorUtils::alphaBlend(color foreground, color background)
     *
     * Returns the result of overlaying the foreground color on the background
     * color.
     *
     * \a foreground The color to overlay on the background.
     *
     * \a background The color to overlay the foreground on.
     *
     * \qml
     * import QtQuick
     * import org.kde.kirigami as Kirigami
     *
     * Rectangle {
     *     color: Kirigami.ColorUtils.alphaBlend(Qt.rgba(0, 0, 0, 0.5), Qt.rgba(1, 1, 1, 1))
     * }
     * \endqml
     *
     * \since 5.69
     */
    Q_INVOKABLE QColor alphaBlend(const QColor &foreground, const QColor &background);

    /*!
     * \qmlmethod color ColorUtils::linearInterpolation(color one, color two, real balance)
     *
     * Returns a linearly interpolated color between color one and color two.
     *
     * \a one The color to linearly interpolate from.
     *
     * \a two The color to linearly interpolate to.
     *
     * \a balance The balance between the two colors. 0.0 will return the
     * first color, 1.0 will return the second color. Values beyond these bounds
     * are valid, and will result in extrapolation.
     *
     * \qml
     * import QtQuick
     * import org.kde.kirigami as Kirigami
     *
     * Rectangle {
     *     color: Kirigami.ColorUtils.linearInterpolation("black", "white", 0.5)
     * }
     * \endqml
     *
     * \since 5.69
     */
    Q_INVOKABLE QColor linearInterpolation(const QColor &one, const QColor &two, double balance);

    /*!
     * \qmlmethod color ColorUtils::adjustColor
     *
     * Increases or decreases the properties of color by fixed amounts.
     *
     * \a color The color to adjust.
     *
     * \a adjustments The adjustments to apply to the color.
     *
     * \qml
     * {
     *     red: null, // Range: -255 to 255
     *     green: null, // Range: -255 to 255
     *     blue: null, // Range: -255 to 255
     *     hue: null, // Range: -360 to 360
     *     saturation: null, // Range: -255 to 255
     *     value: null // Range: -255 to 255
     *     alpha: null, // Range: -255 to 255
     * }
     * \endqml
     *
     * \warning It is an error to adjust both RGB and HSV properties.
     *
     * \since 5.69
     */
    Q_INVOKABLE QColor adjustColor(const QColor &color, const QJSValue &adjustments);

    /*!
     * \qmlmethod color ColorUtils::scaleColor
     *
     * Smoothly scales colors.
     *
     * \a color The color to adjust.
     *
     * \a adjustments The adjustments to apply to the color. Each value must
     * be between `-100.0` and `100.0`. This indicates how far the property should
     * be scaled from its original to the maximum if positive or to the minimum if
     * negative.
     *
     * \qml
     * {
     *     red: null
     *     green: null
     *     blue: null
     *     saturation: null
     *     value: null
     *     alpha: null
     * }
     * \endqml
     *
     * \warning It is an error to scale both RGB and HSV properties.
     *
     * \since 5.69
     */
    Q_INVOKABLE QColor scaleColor(const QColor &color, const QJSValue &adjustments);

    /*!
     * \qmlmethod color ColorUtils::tintWithAlpha
     *
     * Tint a color using a separate alpha value.
     *
     * This does the same as Qt.tint() except that rather than using the tint
     * color's alpha value, it uses a separate value that gets multiplied with
     * the tint color's alpha. This avoids needing to create a new color just to
     * adjust an alpha value.
     *
     * \a targetColor The color to tint.
     *
     * \a tintColor The color to tint with.
     *
     * \a alpha The amount of tinting to apply.
     *
     * \sa Qt.tint()
     */
    Q_INVOKABLE QColor tintWithAlpha(const QColor &targetColor, const QColor &tintColor, double alpha);

    /*!
     * \qmlmethod real ColorUtils::chroma
     *
     * Returns the CIELAB chroma of the given color.
     *
     * CIELAB chroma may give a better quantification of how vibrant a color is compared to HSV saturation.
     *
     * \sa {https://en.wikipedia.org/wiki/Colorfulness} {Colorfulness (Wikipedia)}
     * \sa {https://en.wikipedia.org/wiki/CIELAB_color_space} {CIELAB Color Space (Wikipedia)}
     */
    Q_INVOKABLE static qreal chroma(const QColor &color);

    struct XYZColor {
        qreal x = 0;
        qreal y = 0;
        qreal z = 0;
    };

    struct LabColor {
        qreal l = 0;
        qreal a = 0;
        qreal b = 0;
    };

    // Not for QML, returns the comvertion from srgb of a QColor and XYZ colorspace
    static ColorUtils::XYZColor colorToXYZ(const QColor &color);

    // Not for QML, returns the comvertion from srgb of a QColor and Lab colorspace
    static ColorUtils::LabColor colorToLab(const QColor &color);

    static qreal luminance(const QColor &color);
};
