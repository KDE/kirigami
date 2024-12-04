// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#ifndef SPELLCHECKATTACHED_H
#define SPELLCHECKATTACHED_H

#include <QObject>
#include <QQmlEngine>

#include <qqmlregistration.h>

/*!
 * \qmltype SpellCheck
 * \inqmlmodule org.kde.kirigami
 *
 * \brief This attached property contains hints for spell checker.
 *
 * \warning Kirigami doesn't provide any spell checker per se, this is just a
 * hint for QQC2 style implementation and other downstream components. If you
 * want to  add spell checking to your custom application theme check out Sonnet.
 *
 * \code
 * import QtQuick.Controls as QQC2
 * import org.kde.kirigami as Kirigami
 *
 * QQC2.TextArea {
 *    Kirigami.SpellCheck.enabled: true
 * }
 * \endcode
 *
 * \since 2.18
 */
class SpellCheckAttached : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_NAMED_ELEMENT(SpellCheck)
    QML_UNCREATABLE("Attached property only")
    QML_ATTACHED(SpellCheckAttached)

    /*!
     * \qmlattachedproperty bool SpellCheck::enabled
     *
     * This property holds whether the spell checking should be enabled on the
     * TextField/TextArea.
     *
     * \note By default, false. This might change in KF6, so if you don't want
     * spellcheck in your application, explicitly set it to false.
     *
     * \since 2.18
     */
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged FINAL)
public:
    explicit SpellCheckAttached(QObject *parent = nullptr);
    ~SpellCheckAttached() override;

    void setEnabled(bool enabled);
    bool enabled() const;

    // QML attached property
    static SpellCheckAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void enabledChanged();

private:
    bool m_enabled = false;
};

QML_DECLARE_TYPEINFO(SpellCheckAttached, QML_HAS_ATTACHED_PROPERTIES)

#endif // SPELLCHECKATTACHED_H
