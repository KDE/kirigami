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

// TODO qdoc document?
class KIRIGAMIPLATFORM_EXPORT StyleSelector
{
public:
    static QString style();
    static QStringList styleChain();

    static QUrl componentUrl(const QString &fileName);

    static void setBaseUrl(const QUrl &baseUrl);

    static QString resolveFilePath(const QString &path);
    static QString resolveFileUrl(const QString &path);

private:
    inline static QUrl s_baseUrl;
    inline static QStringList s_styleChain;
};

}
}

#endif // STYLESELECTOR_H
