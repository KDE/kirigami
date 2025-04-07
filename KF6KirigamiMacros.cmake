# SPDX-FileCopyrightText: 2016 Marco Martin <notmart@gmail.com>
# SPDX-FileCopyrightText: 2023 Volker Krause <vkrause@kde.org>
# SPDX-FileCopyrightText: 2025 Carl Schwan <carl@carlschwan.eu>
# SPDX-License-Identifier: BSD-2-Clause

include(CMakeParseArguments)
include(ExternalProject)

function(kirigami_package_breeze_icons)
    set(_multiValueArgs ICONS)
    cmake_parse_arguments(ARG "" "" "${_multiValueArgs}" ${ARGN} )

    if(NOT ARG_ICONS)
        message(FATAL_ERROR "No ICONS argument given to kirigami_package_breeze_icons")
    endif()

    if(NOT ANDROID)
        return() # not needed on other platforms
    endif()

    #include icons used by Kirigami components themselves
    set(ARG_ICONS ${ARG_ICONS}
        application-exit
        dialog-close
        dialog-error
        dialog-information
        dialog-positive
        dialog-warning
        edit-clear-locationbar-ltr
        edit-clear-locationbar-rtl
        edit-copy
        edit-delete-remove
        emblem-error
        emblem-information
        emblem-success
        emblem-warning
        globe
        go-next
        go-next-symbolic
        go-next-symbolic-rtl
        go-previous
        go-previous-symbolic
        go-previous-symbolic-rtl
        go-up
        handle-sort
        mail-sent
        open-menu-symbolic
        overflow-menu-left
        overflow-menu-right
        overflow-menu
        password-show-off
        password-show-on
        tools-report-bug
        user
        view-left-new
        view-right-new
        view-left-close
        view-right-close
    )

    function(_find_breeze_icon icon)
        foreach(_size 48 32 22 16 12)
            SET(path "")
            file(GLOB_RECURSE path ${_BREEZEICONS_DIR}/icons/*/${_size}/${icon}.svg)
            if (path STREQUAL "")
                continue()
            endif()

            list(LENGTH path _count_paths)
            if (_count_paths GREATER 1)
                message(WARNING "Found more than one version of '${icon}': ${path}")
            endif()
            list(GET path 0 path)

            get_filename_component(realpath "${path}" REALPATH)
            if (EXISTS ${realpath})
                install(FILES ${realpath} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami/breeze-internal/icons/${_size})
            endif()

            # Create direct symlink if original icon was also a symlink
            # We can't reuse the existing symlink because often it's a chain
            # of symlink and we can only get the final destination.
            if (NOT "${realpath}" MATCHES "${path}")
                get_filename_component(filename "${realpath}" NAME)
                file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${_size}/")
                file(CREATE_LINK ${filename} "${CMAKE_CURRENT_BINARY_DIR}/${_size}/${icon}.svg" SYMBOLIC)
                install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${_size}/${icon}.svg"
                    DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami/breeze-internal/icons/${_size})
            endif()

        endforeach()
    endfunction()

    if (BREEZEICONS_DIR AND NOT EXISTS ${BREEZEICONS_DIR})
        message(FATAL_ERROR "BREEZEICONS_DIR variable does not point to existing dir: \"${BREEZEICONS_DIR}\"")
    endif()

    set(_BREEZEICONS_DIR "${BREEZEICONS_DIR}")

    #FIXME: this is a terrible hack
    if(NOT _BREEZEICONS_DIR)
        set(_BREEZEICONS_DIR "${CMAKE_BINARY_DIR}/breeze-icons/src/breeze-icons")

        # replacement for ExternalProject_Add not yet working
        # first time config?
        if (NOT EXISTS ${_BREEZEICONS_DIR})
            find_package(Git)
            execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 https://invent.kde.org/frameworks/breeze-icons.git ${_BREEZEICONS_DIR})
        endif()
    endif()

    message (STATUS "Found external breeze icons:")
    foreach(_iconName ${ARG_ICONS})
        _find_breeze_icon(${_iconName})
    endforeach()

    #generate an index.theme that qiconloader can understand
    file(WRITE ${CMAKE_BINARY_DIR}/index.theme "[Icon Theme]\nName=Breeze\nDirectories=icons/12,icons/16,icons/22,icons/32,icons/48\nFollowsColorScheme=true\n[icons/12]\nSize=12\nType=Fixed\n[icons/12]\nSize=12\nType=Fixed\n[icons/16]\nSize=16\nType=Fixed\n[icons/22]\nSize=22\nType=Fixed\n[icons/48]\nSize=48\nType=Fixed")
    install(FILES ${CMAKE_BINARY_DIR}/index.theme DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami/breeze-internal/)
endfunction()
