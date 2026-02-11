/*
 * SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef STYLESELECTOR_H
#define STYLESELECTOR_H

#include <QStringList>
#include <QUrl>

#include "kirigamiplatform_export.h"

class QUrl;

namespace Kirigami
{
namespace Platform
{

class KIRIGAMIPLATFORM_EXPORT StyleSelector
{
public:
    static QString style();
    static QStringList styleChain();

    /*!
     * Find the URL of a component contained in a specific submodule.
     */
    static QUrl componentUrlForModule(const QString &module, const QString &fileName);

    static QString resolveFilePath(const QString &path);

    static QString installRoot();

#if KIRIGAMIPLATFORM_ENABLE_DEPRECATED_SINCE(6, 24)
    KIRIGAMIPLATFORM_DEPRECATED_VERSION(6, 24, "Use componentUrlForModule")
    static QUrl componentUrl(const QString &fileName);

    KIRIGAMIPLATFORM_DEPRECATED_VERSION(6, 24, "No longer used")
    static void setBaseUrl(const QUrl &baseUrl);

    KIRIGAMIPLATFORM_DEPRECATED_VERSION(6, 24, "Does the same as resolveFilePath now")
    static QString resolveFileUrl(const QString &path);
#endif

private:
    inline static QStringList s_styleChain;
};

}
}

#endif // STYLESELECTOR_H
