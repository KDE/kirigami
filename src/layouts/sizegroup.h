/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QMap>
#include <QObject>
#include <QPair>
#include <QPointer>
#include <QQmlListProperty>
#include <QQmlParserStatus>
#include <QQuickItem>

/*!
 * \qmltype SizeGroup
 * \inqmlmodule org.kde.kirigami.layouts
 *
 * \brief SizeGroup is a utility object that makes groups of items request the same size.
 */
class SizeGroup : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    QML_ELEMENT
    Q_INTERFACES(QQmlParserStatus)

public:
    enum Mode {
        None = 0, /// SizeGroup does nothing
        Width = 1, /// SizeGroup syncs item widths
        Height = 2, /// SizeGroup syncs item heights
        Both = 3, /// SizeGroup syncs both item widths and heights
    };
    Q_ENUM(Mode)
    Q_DECLARE_FLAGS(Modes, Mode)

private:
    Mode m_mode = None;
    QList<QPointer<QQuickItem>> m_items;
    QMap<QQuickItem *, QPair<QMetaObject::Connection, QMetaObject::Connection>> m_connections;

public:
    /*!
     * \qmlproperty enumeration SizeGroup::mode
     * Which dimensions this SizeGroup should adjust.
     *
     * Possible values are:
     * \list
     * \li None: SizeGroup does nothing
     * \li Width: SizeGroup syncs item widths
     * \li Height: SizeGroup syncs item heights
     * \li Both: SizeGroup syncs both item widths and heights
     * \endlist
     */
    Q_PROPERTY(Mode mode MEMBER m_mode NOTIFY modeChanged FINAL)
    Q_SIGNAL void modeChanged();

    /*!
     * \qmlproperty list<Item> SizeGroup::items
     * Which items this SizeGroup should adjust
     */
    Q_PROPERTY(QQmlListProperty<QQuickItem> items READ items CONSTANT FINAL)
    QQmlListProperty<QQuickItem> items();

    void adjustItems(Mode whatChanged);
    void connectItem(QQuickItem *item);

    /*!
     * \qmlmethod void SizeGroup::relayout()
     * Forces the SizeGroup to relayout items.
     *
     * Normally this is never needed as the SizeGroup automatically
     * relayout items as they're added and their sizes change.
     */
    Q_INVOKABLE void relayout();

    void classBegin() override
    {
    }
    void componentComplete() override;

private:
    static void appendItem(QQmlListProperty<QQuickItem> *prop, QQuickItem *value);
    static qsizetype itemCount(QQmlListProperty<QQuickItem> *prop);
    static QQuickItem *itemAt(QQmlListProperty<QQuickItem> *prop, qsizetype index);
    static void clearItems(QQmlListProperty<QQuickItem> *prop);
};
