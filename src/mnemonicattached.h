/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef MNEMONICATTACHED_H
#define MNEMONICATTACHED_H

#include <QObject>
#include <QQuickWindow>

#include <QQmlEngine>

/*!
 * \qmltype MnemonicData
 * \inqmlmodule org.kde.kirigami
 *
 * \brief An attached property used to calculate automated keyboard sequences
 * to trigger actions based upon their text.
 *
 * If an "&" mnemonic is used (such as "&Ok"), the system will attempt to assign
 * the desired letter giving it priority, otherwise a letter among the ones
 * in the label will be used if possible and not conflicting.
 *
 * Different kinds of controls will have different priorities in assigning the
 * shortcut: for instance the "Ok/Cancel" buttons in a dialog will have priority
 * over fields of a FormLayout.
 *
 * Usually the developer shouldn't use this directly as base components
 * already use this, but only when implementing a custom graphical Control.
 * \since 2.3
 */
class MnemonicAttached : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MnemonicData)
    QML_ATTACHED(MnemonicAttached)
    QML_UNCREATABLE("Cannot create objects of type MnemonicData, use it as an attached property")

    /*!
     * \qmlattachedproperty string MnemonicData::label
     *
     * The label of the control we want to compute a mnemonic for, instance
     * "Label:" or "&Ok"
     */
    Q_PROPERTY(QString label READ label WRITE setLabel NOTIFY labelChanged FINAL)

    /*!
     * \qmlattachedproperty string MnemonicData::richTextLabel
     *
     * The user-visible final label, which will have the shortcut letter underlined,
     * such as "<u>O</u>k".
     */
    Q_PROPERTY(QString richTextLabel READ richTextLabel NOTIFY richTextLabelChanged FINAL)

    /*!
     * \qmlattachedproperty string MnemonicData::mnemonicLabel
     *
     * The label with an "&" mnemonic in the place which will have the shortcut
     * assigned, regardless of whether the & was assigned by the user or automatically generated.
     */
    Q_PROPERTY(QString mnemonicLabel READ mnemonicLabel NOTIFY mnemonicLabelChanged FINAL)

    /*!
     * \qmlattachedproperty string MnemonicData::plainTextLabel
     *
     * The label in plain text with no markup nor & markers.
     */
    Q_PROPERTY(QString plainTextLabel READ plainTextLabel NOTIFY plainTextLabelChanged FINAL)

    /*!
     * \qmlattachedproperty bool MnemonicData::enabled
     *
     * Only if true this mnemonic will be considered for the global assignment.
     *
     * default: true
     */
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged FINAL)

    /*!
     * \qmlattachedproperty enumeration MnemonicData::controlType
     *
     * The type of control this mnemonic is attached: different types of controls have different importance and priority for shortcut assignment.
     *
     * \qmlenumeratorsfrom MnemonicAttached::ControlType
     */
    Q_PROPERTY(MnemonicAttached::ControlType controlType READ controlType WRITE setControlType NOTIFY controlTypeChanged FINAL)

    /*!
     * \qmlattachedproperty keysequence MnemonicData::sequence
     *
     * The final key sequence assigned, if any: it will be Alt+alphanumeric char.
     */
    Q_PROPERTY(QKeySequence sequence READ sequence NOTIFY sequenceChanged FINAL)

    /*!
     * \qmlattachedproperty bool MnemonicData::active
     *
     * True when the user is pressing alt and the accelerators should be shown.
     *
     * \since 5.72
     * \since 2.15
     */
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged FINAL)

public:
    /*!
     * \value ActionElement pushbuttons, checkboxes etc
     * \value DialogButton buttons for dialogs
     * \value MenuItem Menu items
     * \value FormLabel Buddy label in a FormLayout
     * \value SecondaryControl Other controls that are considered not much important and low priority for shortcuts
     */
    enum ControlType {
        ActionElement,
        DialogButton,
        MenuItem,
        FormLabel,
        SecondaryControl,
    };
    Q_ENUM(ControlType)

    explicit MnemonicAttached(QObject *parent = nullptr);
    ~MnemonicAttached() override;

    void setLabel(const QString &text);
    QString label() const;

    QString richTextLabel() const;
    QString mnemonicLabel() const;
    QString plainTextLabel() const;

    void setEnabled(bool enabled);
    bool enabled() const;

    void setControlType(MnemonicAttached::ControlType controlType);
    ControlType controlType() const;

    QKeySequence sequence();

    void setActive(bool active);
    bool active() const;

    // QML attached property
    static MnemonicAttached *qmlAttachedProperties(QObject *object);

protected:
    void updateSequence();

Q_SIGNALS:
    void labelChanged();
    void enabledChanged();
    void sequenceChanged();
    void richTextLabelChanged();
    void mnemonicLabelChanged();
    void plainTextLabelChanged();
    void controlTypeChanged();
    void activeChanged();

private:
    QWindow *window() const;

    void onAltPressed();
    void onAltReleased();

    void calculateWeights();

    // TODO: to have support for DIALOG_BUTTON_EXTRA_WEIGHT etc, a type enum should be exported
    enum {
        // Additional weight for first character in string
        FIRST_CHARACTER_EXTRA_WEIGHT = 50,
        // Additional weight for the beginning of a word
        WORD_BEGINNING_EXTRA_WEIGHT = 50,
        // Additional weight for a 'wanted' accelerator ie string with '&'
        WANTED_ACCEL_EXTRA_WEIGHT = 150,
        // Default weight for an 'action' widget (ie, pushbuttons)
        ACTION_ELEMENT_WEIGHT = 50,
        // Additional weight for the dialog buttons (large, we basically never want these reassigned)
        DIALOG_BUTTON_EXTRA_WEIGHT = 300,
        // Weight for FormLayout labels (low)
        FORM_LABEL_WEIGHT = 20,
        // Weight for Secondary controls which are considered less important (low)
        SECONDARY_CONTROL_WEIGHT = 10,
        // Default weight for menu items
        MENU_ITEM_WEIGHT = 250,
    };

    // order word letters by weight
    int m_weight = 0;
    int m_baseWeight = 0;
    ControlType m_controlType = SecondaryControl;
    QMap<int, QChar> m_weights;

    QString m_label;
    QString m_actualRichTextLabel;
    QString m_richTextLabel;
    QString m_mnemonicLabel;
    QKeySequence m_sequence;
    bool m_enabled = true;
    bool m_active = false;

    QPointer<QQuickWindow> m_window;

    // global mapping of mnemonics
    // TODO: map by QWindow
    static QHash<QKeySequence, MnemonicAttached *> s_sequenceToObject;
};

QML_DECLARE_TYPEINFO(MnemonicAttached, QML_HAS_ATTACHED_PROPERTIES)

#endif // MnemonicATTACHED_H
