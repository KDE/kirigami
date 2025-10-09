/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef SCENEPOSITIONATTACHED_H
#define SCENEPOSITIONATTACHED_H

#include <QObject>
#include <QQmlEngine>
#include <QQuickWindow>

class QQuickItem;

/*!
 * \qmltype ScenePosition
 * \inqmlmodule org.kde.kirigami
 *
 * \brief An attached property that contains the information about the scene position of the item.
 *
 * Its global x and y coordinates will update automatically and can be binded.
 * \code
 * import org.kde.kirigami as Kirigami
 * Text {
 *    text: ScenePosition.x
 * }
 * \endcode
 */
class ScenePositionAttached : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(ScenePositionAttached)
    QML_NAMED_ELEMENT(ScenePosition)
    QML_UNCREATABLE("")

    /*! \qmlattachedproperty double org.kde.kirigami::ScenePosition::x
     *
     * The global scene X position
     *
     */
    Q_PROPERTY(qreal x READ x NOTIFY xChanged FINAL)

    /*! \qmlattachedproperty double org.kde.kirigami::ScenePosition::y
     *
     * The global scene Y position
     *
     */
    Q_PROPERTY(qreal y READ y NOTIFY yChanged FINAL)

    Q_PROPERTY(qreal devicePixelRatio READ devicePixelRatio NOTIFY devicePixelRatioChanged FINAL)
public:
    explicit ScenePositionAttached(QObject *parent = nullptr);
    ~ScenePositionAttached() override;

    qreal x() const;
    qreal y() const;

    qreal devicePixelRatio() const;
    // QML attached property
    static ScenePositionAttached *qmlAttachedProperties(QObject *object);

    bool eventFilter(QObject *watched, QEvent *event) override;

Q_SIGNALS:
    void xChanged();
    void yChanged();

    void devicePixelRatioChanged();

private:
    void connectAncestors(QQuickItem *item);

    QQuickItem *m_item = nullptr;
    QPointer<QQuickWindow> m_itemWindow;
    QList<QQuickItem *> m_ancestors;
};

QML_DECLARE_TYPEINFO(ScenePositionAttached, QML_HAS_ATTACHED_PROPERTIES)

#endif // SCENEPOSITIONATTACHED_H
