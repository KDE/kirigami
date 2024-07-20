/*
 *  SPDX-FileCopyrightText: 2021 Jonah Brüchert <jbb@kaidan.im>
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMI_UNITS_H
#define KIRIGAMI_UNITS_H

#include <memory>

#include <QObject>
#include <QQmlEngine>

#include "kirigamiplatform_export.h"

class QQmlEngine;

namespace Kirigami
{
namespace Platform
{
class Units;
class UnitsPrivate;

/*!
 * @class IconSizes units.h <Kirigami/Units>
 *
 * Provides access to platform-dependent icon sizing
 */
class KIRIGAMIPLATFORM_EXPORT IconSizes : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Grouped Property")

    Q_PROPERTY(int sizeForLabels READ sizeForLabels NOTIFY sizeForLabelsChanged FINAL)
    Q_PROPERTY(int small READ small NOTIFY smallChanged FINAL)
    Q_PROPERTY(int smallMedium READ smallMedium NOTIFY smallMediumChanged FINAL)
    Q_PROPERTY(int medium READ medium NOTIFY mediumChanged FINAL)
    Q_PROPERTY(int large READ large NOTIFY largeChanged FINAL)
    Q_PROPERTY(int huge READ huge NOTIFY hugeChanged FINAL)
    Q_PROPERTY(int enormous READ enormous NOTIFY enormousChanged FINAL)

public:
    IconSizes(Units *units);

    int sizeForLabels() const;
    int small() const;
    int smallMedium() const;
    int medium() const;
    int large() const;
    int huge() const;
    int enormous() const;

    Q_INVOKABLE int roundedIconSize(int size) const;

private:
    KIRIGAMIPLATFORM_NO_EXPORT float iconScaleFactor() const;

    Units *m_units;

Q_SIGNALS:
    void sizeForLabelsChanged();
    void smallChanged();
    void smallMediumChanged();
    void mediumChanged();
    void largeChanged();
    void hugeChanged();
    void enormousChanged();
};

/*!
 * @class Units units.h <Kirigami/Units>
 *
 * A set of values to define semantically sizes and durations.
 */
class KIRIGAMIPLATFORM_EXPORT Units : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    friend class IconSizes;

    /*!
     * The fundamental unit of space that should be used for sizes, expressed in pixels.
     */
    Q_PROPERTY(int gridUnit READ gridUnit NOTIFY gridUnitChanged FINAL)

    /*!
     * units.iconSizes provides access to platform-dependent icon sizing
     *
     * The icon sizes provided are normalized for different DPI, so icons
     * will scale depending on the DPI.
     *
     * * sizeForLabels (the largest icon size that fits within fontMetrics.height) \since Kirigami 5.80 \since Kirigami org.kde.kirigami 2.16
     * * small
     * * smallMedium
     * * medium
     * * large
     * * huge
     * * enormous
     */
    Q_PROPERTY(Kirigami::Platform::IconSizes *iconSizes READ iconSizes CONSTANT FINAL)

    /*!
     * This property holds the amount of spacing that should be used between smaller UI elements,
     * such as a small icon and a label in a button.
     */
    Q_PROPERTY(int smallSpacing READ smallSpacing NOTIFY smallSpacingChanged FINAL)

    /*!
     * This property holds the amount of spacing that should be used between medium UI elements,
     * such as buttons and text fields in a toolbar.
     */
    Q_PROPERTY(int mediumSpacing READ mediumSpacing NOTIFY mediumSpacingChanged FINAL)

    /*!
     * This property holds the amount of spacing that should be used between bigger UI elements,
     * such as a large icon and a heading in a card.
     */
    Q_PROPERTY(int largeSpacing READ largeSpacing NOTIFY largeSpacingChanged FINAL)

    /*!
     * units.veryLongDuration should be used for specialty animations that benefit
     * from being even longer than longDuration.
     */
    Q_PROPERTY(int veryLongDuration READ veryLongDuration NOTIFY veryLongDurationChanged FINAL)

    /*!
     * units.longDuration should be used for longer, screen-covering animations, for opening and
     * closing of dialogs and other "not too small" animations
     */
    Q_PROPERTY(int longDuration READ longDuration NOTIFY longDurationChanged FINAL)

    /*!
     * units.shortDuration should be used for short animations, such as accentuating a UI event,
     * hover events, etc..
     */
    Q_PROPERTY(int shortDuration READ shortDuration NOTIFY shortDurationChanged FINAL)

    /*!
     * units.veryShortDuration should be used for elements that should have a hint of smoothness,
     * but otherwise animate near instantly.
     */
    Q_PROPERTY(int veryShortDuration READ veryShortDuration NOTIFY veryShortDurationChanged FINAL)

    /*!
     * Time in milliseconds equivalent to the theoretical human moment, which can be used
     * to determine whether how long to wait until the user should be informed of something,
     * or can be used as the limit for how long something should wait before being
     * automatically initiated.
     *
     * Some examples:
     *
     * - When the user types text in a search field, wait no longer than this duration after
     *   the user completes typing before starting the search
     * - When loading data which would commonly arrive rapidly enough to not require interaction,
     *   wait this long before showing a spinner
     *
     * This might seem an arbitrary number, but given the psychological effect that three
     * seconds seems to be what humans consider a moment (and in the case of waiting for
     * something to happen, a moment is that time when you think "this is taking a bit long,
     * isn't it?"), the idea is to postpone for just before such a conceptual moment. The reason
     * for the two seconds, rather than three, is to function as a middle ground: Not long enough
     * that the user would think that something has taken too long, for also not so fast as to
     * happen too soon.
     *
     * See also
     * https://www.psychologytoday.com/blog/all-about-addiction/201101/tick-tock-tick-hugs-and-life-in-3-second-intervals
     * (the actual paper is hidden behind an academic paywall and consequently not readily
     * available to us, so the source will have to be the blog entry above)
     *
     * \note This should __not__ be used as an animation duration, as it is deliberately not scaled according
     * to the animation settings. This is specifically for determining when something has taken too long and
     * the user should expect some kind of feedback. See veryShortDuration, shortDuration, longDuration, and
     * veryLongDuration for animation duration choices.
     *
     * \since Kirigami 5.81
     * \since Kirigami org.kde.kirigami 2.16
     */
    Q_PROPERTY(int humanMoment READ humanMoment NOTIFY humanMomentChanged FINAL)

    /*!
     * time in ms by which the display of tooltips will be delayed.
     *
     * @sa ToolTip.delay property
     */
    Q_PROPERTY(int toolTipDelay READ toolTipDelay NOTIFY toolTipDelayChanged FINAL)

    /*!
     * Corner radius value shared by buttons and other rectangle elements
     *
     * \since Kirigami 6.2
     */
    Q_PROPERTY(qreal cornerRadius READ cornerRadius NOTIFY cornerRadiusChanged FINAL)

public:
    ~Units() override;

    int gridUnit() const;
    void setGridUnit(int size);

    int smallSpacing() const;
    void setSmallSpacing(int size);

    int mediumSpacing() const;
    void setMediumSpacing(int size);

    int largeSpacing() const;
    void setLargeSpacing(int size);

    int veryLongDuration() const;
    void setVeryLongDuration(int duration);

    int longDuration() const;
    void setLongDuration(int duration);

    int shortDuration() const;
    void setShortDuration(int duration);

    int veryShortDuration() const;
    void setVeryShortDuration(int duration);

    int humanMoment() const;
    void setHumanMoment(int duration);

    int toolTipDelay() const;
    void setToolTipDelay(int delay);

    qreal cornerRadius() const;
    void setcornerRadius(qreal cornerRadius);

    IconSizes *iconSizes() const;

    static Units *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

Q_SIGNALS:
    void gridUnitChanged();
    void smallSpacingChanged();
    void mediumSpacingChanged();
    void largeSpacingChanged();
    void veryLongDurationChanged();
    void longDurationChanged();
    void shortDurationChanged();
    void veryShortDurationChanged();
    void humanMomentChanged();
    void toolTipDelayChanged();
    void wheelScrollLinesChanged();
    void cornerRadiusChanged();

protected:
    explicit Units(QObject *parent = nullptr);
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    std::unique_ptr<UnitsPrivate> d;
};

}
}

#endif
