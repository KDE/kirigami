// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QObject>
#include <QtQml>

/**
 * \brief This attached property contains hints for enabling spell checking.
 *
 * \warning Kirigami doesn't provide the spell checking, this is just an hint
 * for the theme. If you want to add spell checking to your custom application
 * theme checkout \ref Sonnet.
 *
 * @code
 * import org.kde.kirigami 2.18 as Kirigami
 * TextArea {
 *    Kirigami.SpellChecking.enabled: true
 * }
 * @endcode
 * @author Carl Schwan <carl@carlschwan.eu>
 * @since 2.18
 */
class SpellCheckingAttached : public QObject
{
    Q_OBJECT
    /**
     * This property holds whether the spell checking should be enabled on the
     * TextField/TextArea.
     *
     * \note By default, false. This might change in KF6, so if you don't want
     * spellchecking on your application, explicitly set it to false.
     *
     * \since 2.18
     */
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
public:
    explicit SpellCheckingAttached(QObject *parent = nullptr);
    ~SpellCheckingAttached() override;

    void setEnabled(bool enabled);
    bool enabled() const;

    // QML attached property
    static SpellCheckingAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void enabledChanged();

private:
    bool m_enabled = false;
};

QML_DECLARE_TYPEINFO(SpellCheckingAttached, QML_HAS_ATTACHED_PROPERTIES)
