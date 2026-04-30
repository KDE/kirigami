/*
 *  SPDX-FileCopyrightText: 2026 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef FORMALIGNMENTGROUP_P_H
#define FORMALIGNMENTGROUP_P_H

#include <QObject>
#include <QPointer>
#include <QQmlListProperty>
#include <qqmlregistration.h>

class QQuickItem;
class FormAlignmentGroupAttached;

/*!
  \qmltype FormAlignmentGroup
  \inqmlmodule org.kde.kirigami.forms

  \brief A group of forms that should be perfectly aligned with each other.

  Sometimes for implementation reasons there must be multiple Form instances in the same
  encompassing layout. when the forms are not in collapsed mode, their tiles and contents need
  to be perfectly aligned with each other, therefore while doing its layout, a form must
  know about all the other forms in the group, so they can synchronize their size hints with each other.

  Use a FormAlignmentGroup instance and its attached property to add every form in the same group

  Example usage:
  \qml
    FormAlignGroup {
        id: formGroup
    }

    Form {
        FormAlignGroup.group: formGroup
        ...
    }

    Form {
        FormAlignGroup.group: formGroup
        ...
    }
  \endqml
  \sa Form
 */
class FormAlignmentGroup : public QObject
{
    Q_OBJECT
    /*!
      All the forms in this group.
     */
    Q_PROPERTY(QQmlListProperty<QQuickItem> forms READ forms NOTIFY formsChanged FINAL)
    QML_ELEMENT
    QML_ATTACHED(FormAlignmentGroupAttached)

public:
    explicit FormAlignmentGroup(QObject *parent = nullptr);

    QQmlListProperty<QQuickItem> forms();

    void addForm(QQuickItem *form);
    void removeForm(QQuickItem *form);

    static FormAlignmentGroupAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void formsChanged();

private:
    static void forms_append(QQmlListProperty<QQuickItem> *prop, QQuickItem *form);
    static qsizetype forms_count(QQmlListProperty<QQuickItem> *prop);
    static QQuickItem *forms_at(QQmlListProperty<QQuickItem> *prop, qsizetype index);
    static void forms_clear(QQmlListProperty<QQuickItem> *prop);

    QList<QQuickItem *> m_forms;
};

class FormAlignmentGroupAttached : public QObject
{
    Q_OBJECT
    /*!
      The group this form belongs to. The attached property makes sense to be used only inside a Form
     */
    Q_PROPERTY(FormAlignmentGroup *group READ group WRITE setGroup NOTIFY groupChanged FINAL)

public:
    explicit FormAlignmentGroupAttached(QObject *parent = nullptr);

    FormAlignmentGroup *group() const;
    void setGroup(FormAlignmentGroup *group);

Q_SIGNALS:
    void groupChanged();

private:
    QQuickItem *m_form = nullptr;
    QPointer<FormAlignmentGroup> m_group;
};

#endif
