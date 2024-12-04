/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef OVERLAYZSTACKINGATTACHED_H
#define OVERLAYZSTACKINGATTACHED_H

#include <QObject>
#include <QQmlEngine>

#include <qqmlregistration.h>

class QQuickItem;

/*!
 * \qmltype OverlayZStacking
 * \inqmlmodule org.kde.kirigami
 *
 * \brief An attached property that manages z-index for stacking overlays relative to each other.
 *
 * When a popup is about to show, OverlayZStacking object kicks in, searches for the
 * next nearest popup in the QtQuick hierarchy of items, and sets its z value to the
 * biggest of two: current stacking value for its layer, or parent's z index + 1.
 *
 * This way OverlayZStacking algorithm ensures that a popup is always stacked higher
 * than its logical parent popup, but also no lower than its siblings on the same
 * logical layer.
 *
 * \code
 * import QtQuick.Controls as QQC2
 * import org.kde.kirigami as Kirigami
 *
 * QQC2.Popup {
 *     Kirigami.OverlayZStacking.layer: Kirigami.OverlayZStacking.ToolTip
 *     z: Kirigami.OverlayZStacking.z
 * }
 * \endcode
 *
 * \since 6.0
 */
class OverlayZStackingAttached : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_NAMED_ELEMENT(OverlayZStacking)
    QML_UNCREATABLE("Cannot create objects of type OverlayZStacking, use it as an attached property")
    QML_ATTACHED(OverlayZStackingAttached)
    /*!
     * \qmlattachedproperty real OverlayZStacking::z
     *
     * An optimal z-index that attachee popup should bind to.
     */
    Q_PROPERTY(qreal z READ z NOTIFY zChanged FINAL)

    /*!
     * \qmlattachedproperty enumeration OverlayZStacking::layer
     *
     * \qmlenumeratorsfrom OverlayZStackingAttached::Layer
     *
     * The logical stacking layer of attachee popup, akin to window manager's layers.
     */
    Q_PROPERTY(Layer layer READ layer WRITE setLayer NOTIFY layerChanged FINAL)

public:
    /*!
     * \value DefaultLowest
     * \value Drawer
     * \value FullScreen
     * \value Dialog
     * \value Menu
     * \value Notification
     * \value ToolTip
     */
    enum Layer {
        DefaultLowest = 0,
        Drawer,
        FullScreen,
        Dialog,
        Menu,
        Notification,
        ToolTip,
    };
    Q_ENUM(Layer)

    explicit OverlayZStackingAttached(QObject *parent = nullptr);
    ~OverlayZStackingAttached() override;

    qreal z() const;

    Layer layer() const;
    void setLayer(Layer layer);

    // QML attached property
    static OverlayZStackingAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void zChanged();
    void layerChanged();

private Q_SLOTS:
    // Popup shall not change z index while being open, so if changes arrive, we defer it until closed.
    void enqueueSignal();
    void dispatchPendingSignal();

    void updateParentPopup();

private:
    void updateParentPopupSilent();
    void setParentPopup(QObject *popup);
    qreal parentPopupZ() const;
    static bool isVisible(const QObject *popup);
    static bool isPopup(const QObject *object);
    static QObject *findParentPopup(const QObject *popup);
    static QQuickItem *findParentPopupItem(const QObject *popup);
    static Layer defaultLayerForPopupType(const QObject *popup);
    static qreal defaultZForLayer(Layer layer);

    Layer m_layer = Layer::DefaultLowest;
    QPointer<QObject> m_parentPopup;
    bool m_pending;
};

QML_DECLARE_TYPEINFO(OverlayZStackingAttached, QML_HAS_ATTACHED_PROPERTIES)

#endif // OVERLAYZSTACKINGATTACHED_H
