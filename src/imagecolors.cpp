/*
 *  SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2024 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "imagecolors.h"

#include <QDebug>
#include <QFutureWatcher>
#include <QGuiApplication>
#include <QtConcurrentRun>

#include "loggingcategory.h"
#include <cmath>
#include <vector>

#include "config-OpenMP.h"
#if HAVE_OpenMP
#include <omp.h>
#endif

#include "platform/platformtheme.h"

#define return_fallback(value)                                                                                                                                 \
    if (m_imageData.m_samples.size() == 0) {                                                                                                                   \
        return value;                                                                                                                                          \
    }

#define return_fallback_finally(value, finally)                                                                                                                \
    if (m_imageData.m_samples.size() == 0) {                                                                                                                   \
        return value.isValid()                                                                                                                                 \
            ? value                                                                                                                                            \
            : static_cast<Kirigami::Platform::PlatformTheme *>(qmlAttachedPropertiesObject<Kirigami::Platform::PlatformTheme>(this, true))->finally();         \
    }

PaletteSwatch::PaletteSwatch()
{
}

PaletteSwatch::PaletteSwatch(qreal ratio, const QColor &color, const QColor &contrastColor)
    : m_ratio(ratio)
    , m_color(color)
    , m_contrastColor(contrastColor)
{
}

qreal PaletteSwatch::ratio() const
{
    return m_ratio;
}

const QColor &PaletteSwatch::color() const
{
    return m_color;
}

const QColor &PaletteSwatch::contrastColor() const
{
    return m_contrastColor;
}

bool PaletteSwatch::operator==(const PaletteSwatch &other) const
{
    return m_ratio == other.m_ratio //
        && m_color == other.m_color //
        && m_contrastColor == other.m_contrastColor;
}

ImageColors::ImageColors(QObject *parent)
    : QObject(parent)
{
}

ImageColors::~ImageColors()
{
}

void ImageColors::setSource(const QVariant &source)
{
    if (m_futureSourceImageData) {
        m_futureSourceImageData->cancel();
        m_futureSourceImageData->deleteLater();
        m_futureSourceImageData = nullptr;
    }

    if (source.canConvert<QQuickItem *>()) {
        setSourceItem(source.value<QQuickItem *>());
    } else if (source.canConvert<QImage>()) {
        setSourceImage(source.value<QImage>());
    } else if (source.canConvert<QIcon>()) {
        setSourceImage(source.value<QIcon>().pixmap(128, 128).toImage());
    } else if (source.canConvert<QString>()) {
        const QString sourceString = source.toString();

        if (QIcon::hasThemeIcon(sourceString)) {
            setSourceImage(QIcon::fromTheme(sourceString).pixmap(128, 128).toImage());
        } else {
            QFuture<QImage> future = QtConcurrent::run([sourceString]() {
                if (auto url = QUrl(sourceString); url.isLocalFile()) {
                    return QImage(url.toLocalFile());
                }
                return QImage(sourceString);
            });
            m_futureSourceImageData = new QFutureWatcher<QImage>(this);
            connect(m_futureSourceImageData, &QFutureWatcher<QImage>::finished, this, [this, source]() {
                const QImage image = m_futureSourceImageData->future().result();
                m_futureSourceImageData->deleteLater();
                m_futureSourceImageData = nullptr;
                setSourceImage(image);
                m_source = source;
                Q_EMIT sourceChanged();
            });
            m_futureSourceImageData->setFuture(future);
            return;
        }
    } else {
        return;
    }

    m_source = source;
    Q_EMIT sourceChanged();
}

QVariant ImageColors::source() const
{
    return m_source;
}

void ImageColors::setSourceImage(const QImage &image)
{
    if (m_window) {
        disconnect(m_window.data(), nullptr, this, nullptr);
    }
    if (m_sourceItem) {
        disconnect(m_sourceItem.data(), nullptr, this, nullptr);
    }
    if (m_grabResult) {
        disconnect(m_grabResult.data(), nullptr, this, nullptr);
        m_grabResult.clear();
    }

    m_sourceItem.clear();

    m_sourceImage = image;
    update();
}

QImage ImageColors::sourceImage() const
{
    return m_sourceImage;
}

void ImageColors::setSourceItem(QQuickItem *source)
{
    if (m_sourceItem == source) {
        return;
    }

    if (m_window) {
        disconnect(m_window.data(), nullptr, this, nullptr);
    }
    if (m_sourceItem) {
        disconnect(m_sourceItem, nullptr, this, nullptr);
    }
    m_sourceItem = source;
    update();

    if (m_sourceItem) {
        auto syncWindow = [this]() {
            if (m_window) {
                disconnect(m_window.data(), nullptr, this, nullptr);
            }
            m_window = m_sourceItem->window();
            if (m_window) {
                connect(m_window, &QWindow::visibleChanged, this, &ImageColors::update);
            }
            update();
        };

        connect(m_sourceItem, &QQuickItem::windowChanged, this, syncWindow);
        syncWindow();
    }
}

QQuickItem *ImageColors::sourceItem() const
{
    return m_sourceItem;
}

void ImageColors::update()
{
    if (m_futureImageData) {
        m_futureImageData->disconnect(this, nullptr);
        m_futureImageData->cancel();
        m_futureImageData->deleteLater();
        m_futureImageData = nullptr;
    }

    auto runUpdate = [this]() {
        auto sourceImage{m_sourceImage};
        QFuture<ImageData> future = QtConcurrent::run([sourceImage = std::move(sourceImage)]() {
            return generatePalette(sourceImage);
        });
        m_futureImageData = new QFutureWatcher<ImageData>(this);
        connect(m_futureImageData, &QFutureWatcher<ImageData>::finished, this, [this]() {
            if (!m_futureImageData) {
                return;
            }
            m_imageData = m_futureImageData->future().result();
            postProcess(m_imageData);
            m_futureImageData->deleteLater();
            m_futureImageData = nullptr;

            Q_EMIT paletteChanged();
        });
        m_futureImageData->setFuture(future);
    };

    if (!m_sourceItem || !m_sourceItem->window() || !m_sourceItem->window()->isVisible()) {
        if (!m_sourceImage.isNull()) {
            runUpdate();
        } else {
            m_imageData = {};
            Q_EMIT paletteChanged();
        }
        return;
    }

    if (m_grabResult) {
        disconnect(m_grabResult.data(), nullptr, this, nullptr);
        m_grabResult.clear();
    }

    m_grabResult = m_sourceItem->grabToImage(QSize(128, 128));

    if (m_grabResult) {
        connect(m_grabResult.data(), &QQuickItemGrabResult::ready, this, [this, runUpdate]() {
            m_sourceImage = m_grabResult->image();
            runUpdate();
        });
        // Workaround for QTBUG-144544
        connect(m_grabResult.data(), &QQuickItemGrabResult::ready, m_grabResult.data(), [grabResult = m_grabResult] {}, Qt::SingleShotConnection);
    }
}

static inline int squareDistance(QRgb color1, QRgb color2)
{
    // https://en.wikipedia.org/wiki/Color_difference
    // Using RGB distance for performance, as CIEDE2000 is too complicated
    if (qRed(color1) - qRed(color2) < 128) {
        return 2 * pow(qRed(color1) - qRed(color2), 2) //
            + 4 * pow(qGreen(color1) - qGreen(color2), 2) //
            + 3 * pow(qBlue(color1) - qBlue(color2), 2);
    } else {
        return 3 * pow(qRed(color1) - qRed(color2), 2) //
            + 4 * pow(qGreen(color1) - qGreen(color2), 2) //
            + 2 * pow(qBlue(color1) - qBlue(color2), 2);
    }
}

void ImageColors::positionColor(QRgb rgb, QList<ImageData::colorStat> &clusters)
{
    for (auto &stat : clusters) {
        if (squareDistance(rgb, stat.centroid) < s_minimumSquareDistance) {
            stat.colors.append(rgb);
            return;
        }
    }

    ImageData::colorStat stat;
    stat.colors.append(rgb);
    stat.centroid = rgb;
    clusters << stat;
}

void ImageColors::positionColorMP(const decltype(ImageData::m_samples) &samples, decltype(ImageData::m_clusters) &clusters, int numCore)
{
#if HAVE_OpenMP
    if (samples.size() < 65536 /* 256^2 */ || numCore < 2) {
#else
    if (true) {
#endif
        // Fall back to single thread
        for (auto color : samples) {
            positionColor(color, clusters);
        }
        return;
    }
#if HAVE_OpenMP
    // Split the whole samples into multiple parts
    const int numSamplesPerThread = samples.size() / numCore;
    std::vector<decltype(ImageData::m_clusters)> tempClusters(numCore, decltype(ImageData::m_clusters){});
#pragma omp parallel for
    for (int i = 0; i < numCore; ++i) {
        const auto beginIt = std::next(samples.begin(), numSamplesPerThread * i);
        const auto endIt = i < numCore - 1 ? std::next(samples.begin(), numSamplesPerThread * (i + 1)) : samples.end();

        for (auto it = beginIt; it != endIt; it = std::next(it)) {
            positionColor(*it, tempClusters[omp_get_thread_num()]);
        }
    } // END omp parallel for

    // Restore clusters
    // Don't use std::as_const as memory will grow significantly
    for (const auto &clusterPart : tempClusters) {
        clusters << clusterPart;
    }
    for (int i = 0; i < clusters.size() - 1; ++i) {
        auto &clusterA = clusters[i];
        if (clusterA.colors.empty()) {
            continue; // Already merged
        }
        for (int j = i + 1; j < clusters.size(); ++j) {
            auto &clusterB = clusters[j];
            if (clusterB.colors.empty()) {
                continue; // Already merged
            }
            if (squareDistance(clusterA.centroid, clusterB.centroid) < s_minimumSquareDistance) {
                // Merge colors in clusterB into clusterA
                clusterA.colors.append(clusterB.colors);
                clusterB.colors.clear();
            }
        }
    }

    auto removeIt = std::remove_if(clusters.begin(), clusters.end(), [](const ImageData::colorStat &stat) {
        return stat.colors.empty();
    });
    clusters.erase(removeIt, clusters.end());
#endif
}

ImageData ImageColors::generatePalette(const QImage &sourceImage)
{
    ImageData imageData;

    if (sourceImage.isNull() || sourceImage.width() == 0) {
        return imageData;
    }

    imageData.m_clusters.clear();
    imageData.m_samples.clear();

#if HAVE_OpenMP
    static const int numCore = std::min(8, omp_get_num_procs());
    omp_set_num_threads(numCore);
#else
    constexpr int numCore = 1;
#endif
    int r = 0;
    int g = 0;
    int b = 0;
    int c = 0;

#pragma omp parallel for collapse(2) reduction(+ : r) reduction(+ : g) reduction(+ : b) reduction(+ : c)
    for (int x = 0; x < sourceImage.width(); ++x) {
        for (int y = 0; y < sourceImage.height(); ++y) {
            const QColor sampleColor = sourceImage.pixelColor(x, y);
            if (sampleColor.alpha() == 0) {
                continue;
            }
            if (ColorUtils::chroma(sampleColor) < 20) {
                continue;
            }
            QRgb rgb = sampleColor.rgb();
            ++c;
            r += qRed(rgb);
            g += qGreen(rgb);
            b += qBlue(rgb);
#pragma omp critical
            imageData.m_samples << rgb;
        }
    } // END omp parallel for

    if (imageData.m_samples.isEmpty()) {
        return imageData;
    }

    positionColorMP(imageData.m_samples, imageData.m_clusters, numCore);

    imageData.m_average = QColor(r / c, g / c, b / c, 255);

    for (int iteration = 0; iteration < 5; ++iteration) {
#pragma omp parallel for private(r, g, b, c)
        for (int i = 0; i < imageData.m_clusters.size(); ++i) {
            auto &stat = imageData.m_clusters[i];
            r = 0;
            g = 0;
            b = 0;
            c = 0;

            for (auto color : std::as_const(stat.colors)) {
                c++;
                r += qRed(color);
                g += qGreen(color);
                b += qBlue(color);
            }
            r = r / c;
            g = g / c;
            b = b / c;
            stat.centroid = qRgb(r, g, b);
            stat.ratio = std::clamp(qreal(stat.colors.count()) / qreal(imageData.m_samples.count()), 0.0, 1.0);
            stat.colors = QList<QRgb>({stat.centroid});
        } // END omp parallel for

        positionColorMP(imageData.m_samples, imageData.m_clusters, numCore);
    }

    std::sort(imageData.m_clusters.begin(), imageData.m_clusters.end(), [](const ImageData::colorStat &a, const ImageData::colorStat &b) {
        return getClusterScore(a) > getClusterScore(b);
    });

    // compress blocks that became too similar
    auto sourceIt = imageData.m_clusters.end();
    // Use index instead of iterator, because QList::erase may invalidate iterator.
    std::vector<int> itemsToDelete;
    while (sourceIt != imageData.m_clusters.begin()) {
        sourceIt--;
        for (auto destIt = imageData.m_clusters.begin(); destIt != imageData.m_clusters.end() && destIt != sourceIt; destIt++) {
            if (squareDistance((*sourceIt).centroid, (*destIt).centroid) < s_minimumSquareDistance) {
                const qreal ratio = (*sourceIt).ratio / (*destIt).ratio;
                const int r = ratio * qreal(qRed((*sourceIt).centroid)) + (1 - ratio) * qreal(qRed((*destIt).centroid));
                const int g = ratio * qreal(qGreen((*sourceIt).centroid)) + (1 - ratio) * qreal(qGreen((*destIt).centroid));
                const int b = ratio * qreal(qBlue((*sourceIt).centroid)) + (1 - ratio) * qreal(qBlue((*destIt).centroid));
                (*destIt).ratio += (*sourceIt).ratio;
                (*destIt).centroid = qRgb(r, g, b);
                itemsToDelete.push_back(std::distance(imageData.m_clusters.begin(), sourceIt));
                break;
            }
        }
    }
    for (auto i : std::as_const(itemsToDelete)) {
        imageData.m_clusters.removeAt(i);
    }

    imageData.m_highlight = QColor();
    imageData.m_dominant = QColor(imageData.m_clusters.first().centroid);
    imageData.m_closestToBlack = Qt::white;
    imageData.m_closestToWhite = Qt::black;

    imageData.m_palette.clear();

    bool first = true;

#pragma omp parallel for ordered
    for (int i = 0; i < imageData.m_clusters.size(); ++i) {
        const auto &stat = imageData.m_clusters[i];
        const QColor color(stat.centroid);

        QColor contrast = QColor(255 - color.red(), 255 - color.green(), 255 - color.blue());
        contrast.setHsl(contrast.hslHue(), //
                        contrast.hslSaturation(), //
                        128 + (128 - contrast.lightness()));
        QColor tempContrast;
        int minimumDistance = 4681800; // max distance: 4*3*2*3*255*255
        for (const auto &stat : std::as_const(imageData.m_clusters)) {
            const int distance = squareDistance(contrast.rgb(), stat.centroid);

            if (distance < minimumDistance) {
                tempContrast = QColor(stat.centroid);
                minimumDistance = distance;
            }
        }

        if (imageData.m_clusters.size() <= 3) {
            if (qGray(imageData.m_dominant.rgb()) < 120) {
                contrast = QColor(230, 230, 230);
            } else {
                contrast = QColor(20, 20, 20);
            }
            // TODO: replace m_clusters.size() > 3 with entropy calculation
        } else if (squareDistance(contrast.rgb(), tempContrast.rgb()) < s_minimumSquareDistance * 1.5) {
            contrast = tempContrast;
        } else {
            contrast = tempContrast;
            contrast.setHsl(contrast.hslHue(),
                            contrast.hslSaturation(),
                            contrast.lightness() > 128 ? qMin(contrast.lightness() + 20, 255) : qMax(0, contrast.lightness() - 20));
        }

#pragma omp ordered
        { // BEGIN omp ordered
            if (first) {
                imageData.m_dominantContrast = contrast;
                imageData.m_dominant = color;
            }
            first = false;

            if (!imageData.m_highlight.isValid() || ColorUtils::chroma(color) > ColorUtils::chroma(imageData.m_highlight)) {
                imageData.m_highlight = color;
            }

            if (qGray(color.rgb()) > qGray(imageData.m_closestToWhite.rgb())) {
                imageData.m_closestToWhite = color;
            }
            if (qGray(color.rgb()) < qGray(imageData.m_closestToBlack.rgb())) {
                imageData.m_closestToBlack = color;
            }
            imageData.m_palette << PaletteSwatch(stat.ratio, color, contrast);
        } // END omp ordered
    }

    return imageData;
}

double ImageColors::getClusterScore(const ImageData::colorStat &stat)
{
    return stat.ratio * ColorUtils::chroma(QColor(stat.centroid));
}

void ImageColors::postProcess(ImageData &imageData) const
{
    constexpr short unsigned WCAG_NON_TEXT_CONTRAST_RATIO = 3;
    constexpr qreal WCAG_TEXT_CONTRAST_RATIO = 4.5;

    auto platformTheme = qmlAttachedPropertiesObject<Kirigami::Platform::PlatformTheme>(this, false);
    if (!platformTheme) {
        return;
    }

    const QColor backgroundColor = static_cast<Kirigami::Platform::PlatformTheme *>(platformTheme)->backgroundColor();
    const qreal backgroundLum = ColorUtils::luminance(backgroundColor);
    qreal lowerLum, upperLum;
    // 192 is from kcm_colors
    if (qGray(backgroundColor.rgb()) < 192) {
        // (lowerLum + 0.05) / (backgroundLum + 0.05) >= 3
        lowerLum = WCAG_NON_TEXT_CONTRAST_RATIO * (backgroundLum + 0.05) - 0.05;
        upperLum = 0.95;
    } else {
        // For light themes, still prefer lighter colors
        // (lowerLum + 0.05) / (textLum + 0.05) >= 4.5
        const QColor textColor =
            static_cast<Kirigami::Platform::PlatformTheme *>(qmlAttachedPropertiesObject<Kirigami::Platform::PlatformTheme>(this, true))->textColor();
        const qreal textLum = ColorUtils::luminance(textColor);
        lowerLum = WCAG_TEXT_CONTRAST_RATIO * (textLum + 0.05) - 0.05;
        upperLum = backgroundLum;
    }

    auto adjustSaturation = [](QColor &color) {
        // Adjust saturation to make the color more vibrant
        if (color.hsvSaturationF() < 0.5) {
            const qreal h = color.hsvHueF();
            const qreal v = color.valueF();
            color.setHsvF(h, 0.5, v);
        }
    };
    adjustSaturation(imageData.m_dominant);
    adjustSaturation(imageData.m_highlight);
    adjustSaturation(imageData.m_average);

    auto adjustLightness = [lowerLum, upperLum](QColor &color) {
        short unsigned colorOperationCount = 0;
        const qreal h = color.hslHueF();
        const qreal s = color.hslSaturationF();
        const qreal l = color.lightnessF();
        while (ColorUtils::luminance(color.rgb()) < lowerLum && colorOperationCount++ < 10) {
            color.setHslF(h, s, std::min(1.0, l + colorOperationCount * 0.03));
        }
        while (ColorUtils::luminance(color.rgb()) > upperLum && colorOperationCount++ < 10) {
            color.setHslF(h, s, std::max(0.0, l - colorOperationCount * 0.03));
        }
    };
    adjustLightness(imageData.m_dominant);
    adjustLightness(imageData.m_highlight);
    adjustLightness(imageData.m_average);
}

QList<PaletteSwatch> ImageColors::palette() const
{
    if (m_futureImageData) {
        qCWarning(KirigamiLog) << m_futureImageData->future().isFinished();
    }
    return_fallback(m_fallbackPalette) return m_imageData.m_palette;
}

ColorUtils::Brightness ImageColors::paletteBrightness() const
{
    /* clang-format off */
    return_fallback(m_fallbackPaletteBrightness)

    return qGray(m_imageData.m_dominant.rgb()) < 128 ? ColorUtils::Dark : ColorUtils::Light;
    /* clang-format on */
}

QColor ImageColors::average() const
{
    /* clang-format off */
    return_fallback_finally(m_fallbackAverage, linkBackgroundColor)

    return m_imageData.m_average;
    /* clang-format on */
}

QColor ImageColors::dominant() const
{
    /* clang-format off */
    return_fallback_finally(m_fallbackDominant, linkBackgroundColor)

    return m_imageData.m_dominant;
    /* clang-format on */
}

QColor ImageColors::dominantContrast() const
{
    /* clang-format off */
    return_fallback_finally(m_fallbackDominantContrasting, linkBackgroundColor)

    return m_imageData.m_dominantContrast;
    /* clang-format on */
}

QColor ImageColors::foreground() const
{
    /* clang-format off */
    return_fallback_finally(m_fallbackForeground, textColor)

    if (paletteBrightness() == ColorUtils::Dark)
    {
        if (qGray(m_imageData.m_closestToWhite.rgb()) < 200) {
            return QColor(230, 230, 230);
        }
        return m_imageData.m_closestToWhite;
    } else {
        if (qGray(m_imageData.m_closestToBlack.rgb()) > 80) {
            return QColor(20, 20, 20);
        }
        return m_imageData.m_closestToBlack;
    }
    /* clang-format on */
}

QColor ImageColors::background() const
{
    /* clang-format off */
    return_fallback_finally(m_fallbackBackground, backgroundColor)

    if (paletteBrightness() == ColorUtils::Dark) {
        if (qGray(m_imageData.m_closestToBlack.rgb()) > 80) {
            return QColor(20, 20, 20);
        }
        return m_imageData.m_closestToBlack;
    } else {
        if (qGray(m_imageData.m_closestToWhite.rgb()) < 200) {
            return QColor(230, 230, 230);
        }
        return m_imageData.m_closestToWhite;
    }
    /* clang-format on */
}

QColor ImageColors::highlight() const
{
    /* clang-format off */
    return_fallback_finally(m_fallbackHighlight, linkColor)

    return m_imageData.m_highlight;
    /* clang-format on */
}

QColor ImageColors::closestToWhite() const
{
    /* clang-format off */
    return_fallback(Qt::white)
    if (qGray(m_imageData.m_closestToWhite.rgb()) < 200) {
        return QColor(230, 230, 230);
    }
    /* clang-format on */

    return m_imageData.m_closestToWhite;
}

QColor ImageColors::closestToBlack() const
{
    /* clang-format off */
    return_fallback(Qt::black)
    if (qGray(m_imageData.m_closestToBlack.rgb()) > 80) {
        return QColor(20, 20, 20);
    }
    /* clang-format on */
    return m_imageData.m_closestToBlack;
}

#include "moc_imagecolors.cpp"
