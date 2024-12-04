/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QVariant>
#include <qqmlregistration.h>

#include "kirigamiplatform_export.h"

namespace Kirigami
{
namespace Platform
{
/*!
 * \qmltype Settings
 * \inqmlmodule org.kde.kirigami.platform
 *
 * \brief Provides global kirigami settings about
 * the current device setup under the singleton "Settings".
 */
class KIRIGAMIPLATFORM_EXPORT Settings : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    /*!
     * \qmlproperty bool Settings::tabletModeAvailable
     *
     * This property holds whether the system can dynamically enter and exit tablet mode
     * (or the device is actually a tablet).
     * This is the case for foldable convertibles and transformable laptops that support
     * keyboard detachment.
     */
    Q_PROPERTY(bool tabletModeAvailable READ isTabletModeAvailable NOTIFY tabletModeAvailableChanged FINAL)

    /*!
     * \qmlproperty bool Settings::isMobile
     *
     * This property holds whether the application is running on a small mobile device
     * such as a mobile phone. This is used when we want to do specific adaptations to
     * the UI for small screen form factors, such as having bigger touch areas.
     */
    Q_PROPERTY(bool isMobile READ isMobile NOTIFY isMobileChanged FINAL)

    /*!
     * \qmlproperty bool Settings::tabletMode
     *
     * This property holds whether the application is running on a device that is
     * behaving like a tablet.
     *
     * \note This doesn't mean exactly a tablet form factor, but
     * that the preferred input mode for the device is the touch screen
     * and that pointer and keyboard are either secondary or not available.
     */
    Q_PROPERTY(bool tabletMode READ tabletMode NOTIFY tabletModeChanged FINAL)

    /*!
     * \qmlproperty bool Settings::hasPlatformMenuBar
     *
     * This property holds whether the system has a platform menu bar; e.g. a user is
     * on macOS or has a global menu on KDE Plasma.
     *
     * \warning Android has a platform menu bar; which may not be what you expected.
     */
    Q_PROPERTY(bool hasPlatformMenuBar READ hasPlatformMenuBar CONSTANT FINAL)

    /*!
     * \qmlproperty bool Settings::hasTransientTouchInput
     *
     * This property holds whether the user in this moment is interacting with the app
     * with the touch screen.
     */
    Q_PROPERTY(bool hasTransientTouchInput READ hasTransientTouchInput NOTIFY hasTransientTouchInputChanged FINAL)

    /*!
     * \qmlproperty string Settings::style
     *
     * This property holds the name of the QtQuickControls2 style the application is using,
     * for instance org.kde.desktop, Plasma, Material, Universal etc
     */
    Q_PROPERTY(QString style READ style CONSTANT FINAL)

    // TODO: make this adapt without file watchers?
    /*!
     * \qmlproperty int Settings::mouseWheelScrollLines
     *
     * This property holds the number of lines of text the mouse wheel should scroll.
     */
    Q_PROPERTY(int mouseWheelScrollLines READ mouseWheelScrollLines CONSTANT FINAL)

    /*!
     * \qmlproperty bool Settings::smoothScroll
     *
     * This property holds whether to display animated transitions when scrolling with a
     * mouse wheel or the keyboard.
     */
    Q_PROPERTY(bool smoothScroll READ smoothScroll NOTIFY smoothScrollChanged FINAL)

    /*!
     * \qmlproperty list<string> Settings::information
     *
     * This property holds the runtime information about the libraries in use.
     *
     * \since 5.52
     * \since org.kde.kirigami 2.6
     */
    Q_PROPERTY(QStringList information READ information CONSTANT FINAL)

    /*!
     * \qmlproperty var Settings::applicationWindowIcon
     * This property holds the name of the application window icon.
     * \sa QGuiApplication::windowIcon()
     *
     * \since 5.62
     * \since org.kde.kirigami 2.10
     */
    Q_PROPERTY(QVariant applicationWindowIcon READ applicationWindowIcon CONSTANT FINAL)

public:
    Settings(QObject *parent = nullptr);
    ~Settings() override;

    void setTabletModeAvailable(bool mobile);
    bool isTabletModeAvailable() const;

    void setIsMobile(bool mobile);
    bool isMobile() const;

    void setTabletMode(bool tablet);
    bool tabletMode() const;

    void setTransientTouchInput(bool touch);
    bool hasTransientTouchInput() const;

    bool hasPlatformMenuBar() const;

    QString style() const;
    void setStyle(const QString &style);

    int mouseWheelScrollLines() const;

    bool smoothScroll() const;

    QStringList information() const;

    QVariant applicationWindowIcon() const;

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

Q_SIGNALS:
    void tabletModeAvailableChanged();
    void tabletModeChanged();
    void isMobileChanged();
    void hasTransientTouchInputChanged();
    void smoothScrollChanged();

private:
    QString m_style;
    int m_scrollLines = 0;
    bool m_smoothScroll : 1;
    bool m_tabletModeAvailable : 1;
    bool m_mobile : 1;
    bool m_tabletMode : 1;
    bool m_hasTouchScreen : 1;
    bool m_hasTransientTouchInput : 1;
    bool m_hasPlatformMenuBar : 1;
};

}
}

#endif
