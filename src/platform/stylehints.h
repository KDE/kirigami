/*
 *  SPDX-FileCopyrightText: 2026 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMI_PLATFORM_STYLEHINTS_H
#define KIRIGAMI_PLATFORM_STYLEHINTS_H

#include <QEvent>
#include <QObject>
#include <QUrl>
#include <qqmlregistration.h>

#include "kirigamiplatform_export.h"

namespace Kirigami
{
namespace Platform
{
/*!
 * \qmltype StyleHints
 * \inqmlmodule org.kde.kirigami.platform
 *
 * \nativetype Kirigami::Platform::StyleHints
 *
 * \brief An attached type that contains hints for styles to use.
 *
 * The properties of StyleHints can be used by QtQuick styles to adjust how
 * certain things look. Generally these properties are used to supplement the
 * QtQuick Controls APIs is some way.
 */

/*!
 * \class Kirigami::Platform::StyleHints
 * \inheaderfile Kirigami/Platform/StyleHints
 * \inmodule KirigamiPlatform
 *
 * \brief A class providing an attached property to set hints for styles to use.
 *
 * This is mostly a class for QtQuick API. However, if you need to trigger
 * specific behaviour in a custom style, you can call setMakeStyleHintsFunction()
 * with a custom factory function to create a custom subclass of this class. The
 * subclass can then respond to property changes of instances of this class.
 */
class KIRIGAMIPLATFORM_EXPORT StyleHints : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(Kirigami::Platform::StyleHints)
    QML_UNCREATABLE("Attached Property")

public:
    enum class ChangedProperty {
        UseAlternateBackgroundColor,
        ShowFramedBackground,
        TickMarkStepSize,
        IconName,
        IconSource,
    };

    explicit StyleHints(QObject *parent = nullptr);
    ~StyleHints() override;

    /*!
     * \qmlproperty bool StyleHints::showFramedBackground
     *
     * Should the background use a framed rather than a plain style.
     *
     * Primarily intended for ScrollViews to indicate that the ScrollView should
     * draw a frame.
     */
    Q_PROPERTY(bool showFramedBackground READ showFramedBackground WRITE setShowFramedBackground NOTIFY showFramedBackgroundChanged)
    bool showFramedBackground() const;
    void setShowFramedBackground(bool newShowFramedBackground);
    Q_SIGNAL void showFramedBackgroundChanged();

    /*!
     * \qmlproperty int StyleHints::tickMarkStepSize
     *
     * The step size to show tick marks at.
     *
     * A step size of 0 or less results in no tick marks being shown.
     * This is mainly intended to be used by sliders.
     */
    Q_PROPERTY(int tickMarkStepSize READ tickMarkStepSize WRITE setTickMarkStepSize NOTIFY tickMarkStepSizeChanged)
    int tickMarkStepSize() const;
    void setTickMarkStepSize(int newTickMarkStepSize);
    Q_SIGNAL void tickMarkStepSizeChanged();

    /*!
     * \qmlproperty string StyleHints::iconName
     *
     * An icon theme name for an icon.
     *
     * To be used for controls that lack their own icon property, such as
     * ComboBox.
     */
    Q_PROPERTY(QString iconName READ iconName WRITE setIconName NOTIFY iconNameChanged)
    QString iconName() const;
    void setIconName(const QString &newIconName);
    Q_SIGNAL void iconNameChanged();

    /*!
     * \qmlproperty url StyleHints::iconSource
     *
     * An icon source URL for an icon.
     *
     * To be used for controls that lack their own icon property, such as
     * ComboBox.
     */
    Q_PROPERTY(QUrl iconSource READ iconSource WRITE setIconSource NOTIFY iconSourceChanged)
    QUrl iconSource() const;
    void setIconSource(const QUrl &newIconSource);
    Q_SIGNAL void iconSourceChanged();

    static StyleHints *qmlAttachedProperties(QObject *object);

    /*!
     * Set a different function to be used by qmlAttachedProperties() to create a StyleHints instance.
     *
     * This is provided to allow different platform plugins to provide their own
     * StyleHints subclass.
     *
     * \todo KF7: This should really be part of PlatformPluginFactory but we
     * cannot add new virtuals to it due to binary compatibility. Once we break
     * binary compatibility, move this to PlatformPluginFactory.
     */
    static void setMakeStyleHintsFunction(const std::function<StyleHints *(QObject *)> &function);

protected:
    /*!
     * Helper function to notify subclasses of a property change.
     *
     * Reimplement this in a subclass to handle a change to one of the
     * properties, without the overhead of making separate signal connections
     * for each property.
     */
    virtual void propertyChanged(ChangedProperty change);

private:
    class Private;
    const std::unique_ptr<Private> d;
};

}
}

#endif // KIRIGAMI_PLATFORM_STYLEHINTS_H
