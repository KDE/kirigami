/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMI_PLATFORMTHEME_H
#define KIRIGAMI_PLATFORMTHEME_H

#include <QColor>
#include <QIcon>
#include <QObject>
#include <QPalette>
#include <QQuickItem>
#include <qqmlregistration.h>

#include "kirigamiplatform_export.h"

namespace Kirigami
{
namespace Platform
{
class PlatformThemeData;
class PlatformThemePrivate;

/*!
 * \qmltype Theme
 * \inqmlmodule org.kde.kirigami.platform
 *
 * \nativetype Kirigami::Platform::PlatformTheme
 *
 * \brief This class is the base for color management in Kirigami,
 * different platforms can reimplement this class to integrate
 * with system platform colors of a given platform.
 */

/*!
 * \class Kirigami::Platform::PlatformTheme
 * \inheaderfile Kirigami/Platform/PlatformTheme
 * \inmodule KirigamiPlatform
 *
 * \brief This class is the base for color management in Kirigami,
 * different platforms can reimplement this class to integrate with
 * system platform colors of a given platform.
 */
class KIRIGAMIPLATFORM_EXPORT PlatformTheme : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(Theme)
    QML_ATTACHED(Kirigami::Platform::PlatformTheme)
    QML_UNCREATABLE("Attached Property")

    /*!
     * \qmlattachedproperty enumeration Theme::colorSet
     * This enumeration describes the color set for which a color is being selected.
     *
     * Color sets define a color "environment", suitable for drawing all parts of a
     * given region. Colors from different sets should not be combined.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::colorSet
     * This enumeration describes the color set for which a color is being selected.
     *
     * Color sets define a color "environment", suitable for drawing all parts of a
     * given region. Colors from different sets should not be combined.
     */
    Q_PROPERTY(ColorSet colorSet READ colorSet WRITE setColorSet NOTIFY colorSetChanged FINAL)

    /*!
     * \qmlattachedproperty enumeration Theme::colorGroup
     *
     * This enumeration describes the color group used to generate the colors.
     * The enum value is based upon QPalette::ColorGroup and has the same values.
     * It's redefined here in order to make it work with QML.
     * \since 4.43
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::colorGroup
     *
     * This enumeration describes the color group used to generate the colors.
     * The enum value is based upon QPalette::ColorGroup and has the same values.
     * It's redefined here in order to make it work with QML.
     * \since 4.43
     */
    Q_PROPERTY(ColorGroup colorGroup READ colorGroup WRITE setColorGroup NOTIFY colorGroupChanged FINAL)

    /*!
     * \qmlattachedproperty bool Theme::inherit
     *
     * If true, the colorSet will be inherited from the colorset of a theme of one
     * of the ancestor items.
     *
     * default: true
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::inherit
     *
     * If true, the colorSet will be inherited from the colorset of a theme of one
     * of the ancestor items.
     *
     * default: true
     */
    Q_PROPERTY(bool inherit READ inherit WRITE setInherit NOTIFY inheritChanged FINAL)

    // foreground colors
    /*!
     * \qmlattachedproperty color Theme::textColor
     * Color for normal foregrounds, usually text, but not limited to it,
     * anything that should be painted with a clear contrast should use this color.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::textColor
     * Color for normal foregrounds, usually text, but not limited to it,
     * anything that should be painted with a clear contrast should use this color.
     */
    Q_PROPERTY(QColor textColor READ textColor WRITE setCustomTextColor RESET setCustomTextColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty color Theme::disabledTextColor
     *
     * Foreground color for disabled areas, usually a mid-gray.
     * \note Depending on the implementation, the color used for this property may not be
     *       based on the disabled palette. For example, for the Plasma implementation,
     *       "Inactive Text Color" of the active palette is used.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::disabledTextColor
     *
     * Foreground color for disabled areas, usually a mid-gray.
     * \note Depending on the implementation, the color used for this property may not be
     *       based on the disabled palette. For example, for the Plasma implementation,
     *       "Inactive Text Color" of the active palette is used.
     */
    Q_PROPERTY(QColor disabledTextColor READ disabledTextColor WRITE setCustomDisabledTextColor RESET setCustomDisabledTextColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty color Theme::highlightedTextColor
     *
     * Color for text that has been highlighted, often is a light color while normal text is dark.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::highlightedTextColor
     *
     * Color for text that has been highlighted, often is a light color while normal text is dark.
     */
    Q_PROPERTY(
        QColor highlightedTextColor READ highlightedTextColor WRITE setCustomHighlightedTextColor RESET setCustomHighlightedTextColor NOTIFY colorsChanged)

    /*!
     * \qmlattachedproperty color Theme::activeTextColor
     *
     * Foreground for areas that are active or requesting attention.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::activeTextColor
     *
     * Foreground for areas that are active or requesting attention.
     */
    Q_PROPERTY(QColor activeTextColor READ activeTextColor WRITE setCustomActiveTextColor RESET setCustomActiveTextColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty color Theme::linkColor
     *
     * Color for links.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::linkColor
     *
     * Color for links.
     */
    Q_PROPERTY(QColor linkColor READ linkColor WRITE setCustomLinkColor RESET setCustomLinkColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty color Theme::visitedLinkColor
     *
     * Color for visited links, usually a bit darker than linkColor.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::visitedLinkColor
     *
     * Color for visited links, usually a bit darker than linkColor.
     */
    Q_PROPERTY(QColor visitedLinkColor READ visitedLinkColor WRITE setCustomVisitedLinkColor RESET setCustomVisitedLinkColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty color Theme::negativeTextColor
     *
     * Foreground color for negative areas, such as critical error text.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::negativeTextColor
     *
     * Foreground color for negative areas, such as critical error text.
     */
    Q_PROPERTY(QColor negativeTextColor READ negativeTextColor WRITE setCustomNegativeTextColor RESET setCustomNegativeTextColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty color Theme::neutralTextColor
     *
     * Foreground color for neutral areas, such as warning texts (but not critical).
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::neutralTextColor
     *
     * Foreground color for neutral areas, such as warning texts (but not critical).
     */
    Q_PROPERTY(QColor neutralTextColor READ neutralTextColor WRITE setCustomNeutralTextColor RESET setCustomNeutralTextColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty color Theme::positiveTextColor
     *
     * Success messages, trusted content.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::positiveTextColor
     *
     * Success messages, trusted content.
     */
    Q_PROPERTY(QColor positiveTextColor READ positiveTextColor WRITE setCustomPositiveTextColor RESET setCustomPositiveTextColor NOTIFY colorsChanged FINAL)

    // background colors
    /*!
     * \qmlattachedproperty color Theme::backgroundColor
     *
     * The generic background color.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::backgroundColor
     *
     * The generic background color.
     */
    Q_PROPERTY(QColor backgroundColor READ backgroundColor WRITE setCustomBackgroundColor RESET setCustomBackgroundColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty color Theme::alternateBackgroundColor
     *
     * The generic background color.
     *
     * Alternate background; for example, for use in lists.
     *
     * This color may be the same as BackgroundNormal,
     * especially in sets other than View and Window.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::alternateBackgroundColor
     *
     * The generic background color.
     *
     * Alternate background; for example, for use in lists.
     *
     * This color may be the same as BackgroundNormal,
     * especially in sets other than View and Window.
     */
    Q_PROPERTY(QColor alternateBackgroundColor READ alternateBackgroundColor WRITE setCustomAlternateBackgroundColor RESET setCustomAlternateBackgroundColor
                   NOTIFY colorsChanged)

    /*!
     * \qmlattachedproperty color Theme::highlightColor
     *
     * The background color for selected areas.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::highlightColor
     *
     * The background color for selected areas.
     */
    Q_PROPERTY(QColor highlightColor READ highlightColor WRITE setCustomHighlightColor RESET setCustomHighlightColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty color Theme::activeBackgroundColor
     *
     * Background for areas that are active or requesting attention.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::activeBackgroundColor
     *
     * Background for areas that are active or requesting attention.
     */
    Q_PROPERTY(
        QColor activeBackgroundColor READ activeBackgroundColor WRITE setCustomActiveBackgroundColor RESET setCustomActiveBackgroundColor NOTIFY colorsChanged)

    /*!
     * \qmlattachedproperty color Theme::linkBackgroundColor
     *
     * Background color for links.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::linkBackgroundColor
     *
     * Background color for links.
     */
    Q_PROPERTY(
        QColor linkBackgroundColor READ linkBackgroundColor WRITE setCustomLinkBackgroundColor RESET setCustomLinkBackgroundColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty color Theme::visitedLinkBackgroundColor
     *
     * Background color for visited links, usually a bit darker than linkBackgroundColor.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::visitedLinkBackgroundColor
     *
     * Background color for visited links, usually a bit darker than linkBackgroundColor.
     */
    Q_PROPERTY(QColor visitedLinkBackgroundColor READ visitedLinkBackgroundColor WRITE setCustomVisitedLinkBackgroundColor RESET
                   setCustomVisitedLinkBackgroundColor NOTIFY colorsChanged)

    /*!
     * \qmlattachedproperty color Theme::negativeBackgroundColor
     *
     * Background color for negative areas, such as critical errors and destructive actions.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::negativeBackgroundColor
     *
     * Background color for negative areas, such as critical errors and destructive actions.
     */
    Q_PROPERTY(QColor negativeBackgroundColor READ negativeBackgroundColor WRITE setCustomNegativeBackgroundColor RESET setCustomNegativeBackgroundColor NOTIFY
                   colorsChanged)

    /*!
     * \qmlattachedproperty color Theme::neutralBackgroundColor
     *
     * Background color for neutral areas, such as warnings (but not critical).
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::neutralBackgroundColor
     *
     * Background color for neutral areas, such as warnings (but not critical).
     */
    Q_PROPERTY(QColor neutralBackgroundColor READ neutralBackgroundColor WRITE setCustomNeutralBackgroundColor RESET setCustomNeutralBackgroundColor NOTIFY
                   colorsChanged)

    /*!
     * \qmlattachedproperty color Theme::positiveBackgroundColor
     *
     * Background color for positive areas, such as success messages and trusted content.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::positiveBackgroundColor
     *
     * Background color for positive areas, such as success messages and trusted content.
     */
    Q_PROPERTY(QColor positiveBackgroundColor READ positiveBackgroundColor WRITE setCustomPositiveBackgroundColor RESET setCustomPositiveBackgroundColor NOTIFY
                   colorsChanged)

    // decoration colors
    /*!
     * \qmlattachedproperty color Theme::focusColor
     *
     * A decoration color that indicates active focus.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::focusColor
     *
     * A decoration color that indicates active focus.
     */
    Q_PROPERTY(QColor focusColor READ focusColor WRITE setCustomFocusColor RESET setCustomFocusColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty color Theme::hoverColor
     *
     * A decoration color that indicates mouse hovering.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::hoverColor
     *
     * A decoration color that indicates mouse hovering.
     */
    Q_PROPERTY(QColor hoverColor READ hoverColor WRITE setCustomHoverColor RESET setCustomHoverColor NOTIFY colorsChanged FINAL)

    /*!
     * \qmlattachedproperty bool Theme::useAlternateBackgroundColor
     *
     * Hint for item views to actually make use of the alternate background color feature.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::useAlternateBackgroundColor
     *
     * Hint for item views to actually make use of the alternate background color feature.
     */
    Q_PROPERTY(
        bool useAlternateBackgroundColor READ useAlternateBackgroundColor WRITE setUseAlternateBackgroundColor NOTIFY useAlternateBackgroundColorChanged FINAL)

    /*!
     * \qmlattachedproperty font Theme::defaultFont
     *
     * The default font.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::defaultFont
     *
     * The default font.
     */
    Q_PROPERTY(QFont defaultFont READ defaultFont NOTIFY defaultFontChanged FINAL)

    /*!
     * \qmlattachedproperty font Theme::smallFont
     *
     * Small font.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::smallFont
     *
     * Small font.
     */
    Q_PROPERTY(QFont smallFont READ smallFont NOTIFY smallFontChanged FINAL)

    /*!
     * \qmlattachedproperty font Theme::fixedWidthFont
     *
     * Fixed width font.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::fixedWidthFont
     *
     * Fixed width font.
     */
    Q_PROPERTY(QFont fixedWidthFont READ fixedWidthFont NOTIFY fixedWidthFontChanged FINAL)

    // Active palette
    /*!
     * \qmlattachedproperty QPalette Theme::palette
     *
     * Palette.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::palette
     *
     * Palette.
     */
    Q_PROPERTY(QPalette palette READ palette NOTIFY paletteChanged FINAL)

    /*!
     * \qmlattachedproperty real Theme::frameContrast
     *
     * Frame contrast value, usually used for separators and outlines
     * Value is between 0.0 and 1.0.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::frameContrast
     *
     * Frame contrast value, usually used for separators and outlines
     * Value is between 0.0 and 1.0.
     */
    Q_PROPERTY(qreal frameContrast READ frameContrast CONSTANT FINAL)

    /*!
     * \qmlattachedproperty real Theme::lightFrameContrast
     *
     * Returns half of the frameContrast value; used by Separator.Weight.Light
     * Value is between 0.0 and 1.0.
     */
    /*!
     * \property Kirigami::Platform::PlatformTheme::lightFrameContrast
     *
     * Returns half of the frameContrast value; used by Separator.Weight.Light
     * Value is between 0.0 and 1.0.
     */
    Q_PROPERTY(qreal lightFrameContrast READ lightFrameContrast CONSTANT FINAL)

public:
    /*!
     * \value View Color set for item views, usually the lightest of all
     * \value Window Default Color set for windows and "chrome" areas
     * \value Button Color set used by buttons
     * \value Selection Color set used by selected areas
     * \value Tooltip Color set used by tooltips
     * \value Complementary Color set meant to be complementary to Window: usually is a dark theme for light themes
     * \value Header Color set to be used by heading areas of applications, such as toolbars
     * \omitvalue ColorSetCount
     */
    enum ColorSet {
        View = 0,
        Window,
        Button,
        Selection,
        Tooltip,
        Complementary,
        Header,
        // Number of items in this enum, this should always be the last item.
        ColorSetCount,
    };
    Q_ENUM(ColorSet)

    /*!
     * \value Disabled
     * \value Active
     * \value Inactive
     * \value Normal
     * \omitvalue ColorGroupCount
     */
    enum ColorGroup {
        Disabled = QPalette::Disabled,
        Active = QPalette::Active,
        Inactive = QPalette::Inactive,
        Normal = QPalette::Normal,

        ColorGroupCount, // Number of items in this enum, this should always be the last item.
    };
    Q_ENUM(ColorGroup)

    explicit PlatformTheme(QObject *parent = nullptr);
    ~PlatformTheme() override;

    void setColorSet(PlatformTheme::ColorSet);
    PlatformTheme::ColorSet colorSet() const;

    void setColorGroup(PlatformTheme::ColorGroup);
    PlatformTheme::ColorGroup colorGroup() const;

    bool inherit() const;
    void setInherit(bool inherit);

    // foreground colors
    QColor textColor() const;
    QColor disabledTextColor() const;
    QColor highlightedTextColor() const;
    QColor activeTextColor() const;
    QColor linkColor() const;
    QColor visitedLinkColor() const;
    QColor negativeTextColor() const;
    QColor neutralTextColor() const;
    QColor positiveTextColor() const;

    // background colors
    QColor backgroundColor() const;
    QColor alternateBackgroundColor() const;
    QColor highlightColor() const;
    QColor activeBackgroundColor() const;
    QColor linkBackgroundColor() const;
    QColor visitedLinkBackgroundColor() const;
    QColor negativeBackgroundColor() const;
    QColor neutralBackgroundColor() const;
    QColor positiveBackgroundColor() const;

    // decoration colors
    QColor focusColor() const;
    QColor hoverColor() const;

    QFont defaultFont() const;
    QFont smallFont() const;
    QFont fixedWidthFont() const;

    // this may is used by the desktop QQC2 to set the styleoption palettes
    QPalette palette() const;

    qreal frameContrast() const;
    qreal lightFrameContrast() const;

    /*!
     * This will be used by desktopicon to fetch icons with KIconLoader.
     */
    virtual Q_INVOKABLE QIcon iconFromTheme(const QString &name, const QColor &customColor = Qt::transparent);

    bool supportsIconColoring() const;

    // foreground colors
    void setCustomTextColor(const QColor &color = QColor());
    void setCustomDisabledTextColor(const QColor &color = QColor());
    void setCustomHighlightedTextColor(const QColor &color = QColor());
    void setCustomActiveTextColor(const QColor &color = QColor());
    void setCustomLinkColor(const QColor &color = QColor());
    void setCustomVisitedLinkColor(const QColor &color = QColor());
    void setCustomNegativeTextColor(const QColor &color = QColor());
    void setCustomNeutralTextColor(const QColor &color = QColor());
    void setCustomPositiveTextColor(const QColor &color = QColor());
    // background colors
    void setCustomBackgroundColor(const QColor &color = QColor());
    void setCustomAlternateBackgroundColor(const QColor &color = QColor());
    void setCustomHighlightColor(const QColor &color = QColor());
    void setCustomActiveBackgroundColor(const QColor &color = QColor());
    void setCustomLinkBackgroundColor(const QColor &color = QColor());
    void setCustomVisitedLinkBackgroundColor(const QColor &color = QColor());
    void setCustomNegativeBackgroundColor(const QColor &color = QColor());
    void setCustomNeutralBackgroundColor(const QColor &color = QColor());
    void setCustomPositiveBackgroundColor(const QColor &color = QColor());
    // decoration colors
    void setCustomFocusColor(const QColor &color = QColor());
    void setCustomHoverColor(const QColor &color = QColor());

#if KIRIGAMIPLATFORM_ENABLE_DEPRECATED_SINCE(6, 24)
    KIRIGAMIPLATFORM_DEPRECATED_VERSION(6, 24, "Use StyleHints::useAlternateBackgroundColor instead")
    bool useAlternateBackgroundColor() const;
    KIRIGAMIPLATFORM_DEPRECATED_VERSION(6, 24, "Use StyleHints::setUseAlternateBackgroundColor instead")
    void setUseAlternateBackgroundColor(bool alternate);
#endif

    // QML attached property
    static PlatformTheme *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void colorsChanged();
    void defaultFontChanged(const QFont &font);
    void smallFontChanged(const QFont &font);
    void fixedWidthFontChanged(const QFont &font);
    void colorSetChanged(Kirigami::Platform::PlatformTheme::ColorSet colorSet);
    void colorGroupChanged(Kirigami::Platform::PlatformTheme::ColorGroup colorGroup);
    void paletteChanged(const QPalette &pal);
    void inheritChanged(bool inherit);
    void useAlternateBackgroundColorChanged(bool alternate);
    void frameContrastChanged(qreal contrast);

protected:
    /// To set in the constructors so the changes trackers can avoid emitting
    void setConstructing(bool isConstructing);

    // Setters, not accessible from QML but from implementations
    void setSupportsIconColoring(bool support);

    // foreground colors
    void setTextColor(const QColor &color);
    void setDisabledTextColor(const QColor &color);
    void setHighlightedTextColor(const QColor &color);
    void setActiveTextColor(const QColor &color);
    void setLinkColor(const QColor &color);
    void setVisitedLinkColor(const QColor &color);
    void setNegativeTextColor(const QColor &color);
    void setNeutralTextColor(const QColor &color);
    void setPositiveTextColor(const QColor &color);

    // background colors
    void setBackgroundColor(const QColor &color);
    void setAlternateBackgroundColor(const QColor &color);
    void setHighlightColor(const QColor &color);
    void setActiveBackgroundColor(const QColor &color);
    void setLinkBackgroundColor(const QColor &color);
    void setVisitedLinkBackgroundColor(const QColor &color);
    void setNegativeBackgroundColor(const QColor &color);
    void setNeutralBackgroundColor(const QColor &color);
    void setPositiveBackgroundColor(const QColor &color);

    // decoration colors
    void setFocusColor(const QColor &color);
    void setHoverColor(const QColor &color);

    void setDefaultFont(const QFont &defaultFont);
    void setSmallFont(const QFont &smallFont);
    void setFixedWidthFont(const QFont &fixedWidthFont);
    void setFrameContrast(qreal contrast);

    bool event(QEvent *event) override;

private:
    KIRIGAMIPLATFORM_NO_EXPORT void update();
    KIRIGAMIPLATFORM_NO_EXPORT void updateChildren(QObject *item);
    KIRIGAMIPLATFORM_NO_EXPORT QObject *determineParent(QObject *object);
    KIRIGAMIPLATFORM_NO_EXPORT void emitSignalsForChanges(int changes);

    PlatformThemePrivate *d;
    friend class PlatformThemePrivate;
    friend class PlatformThemeData;
    friend class PlatformThemeChangeTracker;
};

/*!
 * \brief A class that tracks changes to PlatformTheme properties and emits signals at the right moment.
 * \inheaderfile Kirigami/Platform/PlatformTheme
 * \inmodule KirigamiPlatform
 *
 * This should be used by PlatformTheme implementations to ensure that multiple
 * changes to a PlatformTheme's properties do not emit multiple change signals,
 * instead batching all of them into a single signal emission. This then ensures
 * things making use of PlatformTheme aren't needlessly redrawn or redrawn in a
 * partially changed state.
 *
 * \since 6.7
 *
 */
class KIRIGAMIPLATFORM_EXPORT PlatformThemeChangeTracker
{
public:
    /*!
     * \enum Kirigami::Platform::PlatformThemeChangeTracker::PropertyChange
     * \brief Flags used to indicate changes made to certain properties.
     *
     * \value None
     * \value ColorSet
     * \value ColorGroup
     * \value Color
     * \value Palette
     * \value Font
     * \value Data
     * \value FrameContrast
     * \value All
     */
    enum class PropertyChange : uint8_t {
        None = 0,
        ColorSet = 1 << 0,
        ColorGroup = 1 << 1,
        Color = 1 << 2,
        Palette = 1 << 3,
        Font = 1 << 4,
        Data = 1 << 5,
        FrameContrast = 1 << 6,
        All = ColorSet | ColorGroup | Color | Palette | Font | Data | FrameContrast,
    };
    Q_DECLARE_FLAGS(PropertyChanges, PropertyChange)

    PlatformThemeChangeTracker(PlatformTheme *theme, PropertyChanges changes = PropertyChange::None);
    ~PlatformThemeChangeTracker();

    void markDirty(PropertyChanges changes);

private:
    PlatformTheme *m_theme;

    // Per-PlatformTheme data that we need for PlatformThemeChangeBlocker.
    // We don't want to store this in PlatformTheme since that would increase the
    // size of every instance of PlatformTheme while it's only used when we want to
    // block property change signal emissions. So instead we store it in a separate
    // hash using the PlatformTheme as key.
    struct Data {
        PropertyChanges changes;
    };

    std::shared_ptr<Data> m_data;

    inline static QHash<PlatformTheme *, std::weak_ptr<Data>> s_blockedChanges;
};

namespace PlatformThemeEvents
{
// TODO qdoc document this?
// To avoid the overhead of Qt's signal/slot connections, we use custom events
// to communicate with subclasses. This way, we can indicate what actually
// changed without needing to add new virtual functions to PlatformTheme which
// would break binary compatibility.
//
// To handle these events in your subclass, override QObject::event() and check
// if you receive one of these events, then do what is needed. Finally, make
// sure to call PlatformTheme::event() since that will also do some processing
// of these events.

template<typename T>
class KIRIGAMIPLATFORM_EXPORT PropertyChangedEvent : public QEvent
{
public:
    PropertyChangedEvent(PlatformTheme *theme, const T &previous, const T &current)
        : QEvent(PropertyChangedEvent<T>::type)
        , sender(theme)
        , oldValue(previous)
        , newValue(current)
    {
    }

    PlatformTheme *sender;
    T oldValue;
    T newValue;

    static QEvent::Type type;
};

using DataChangedEvent = PropertyChangedEvent<std::shared_ptr<PlatformThemeData>>;
using ColorSetChangedEvent = PropertyChangedEvent<PlatformTheme::ColorSet>;
using ColorGroupChangedEvent = PropertyChangedEvent<PlatformTheme::ColorGroup>;
using ColorChangedEvent = PropertyChangedEvent<QColor>;
using FontChangedEvent = PropertyChangedEvent<QFont>;
using FrameContrastChangedEvent = PropertyChangedEvent<qreal>;
}

}
} // namespace Kirigami

Q_DECLARE_OPERATORS_FOR_FLAGS(Kirigami::Platform::PlatformThemeChangeTracker::PropertyChanges)

#endif // PLATFORMTHEME_H
