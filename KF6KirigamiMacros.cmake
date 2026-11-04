# SPDX-FileCopyrightText: 2016 Marco Martin <notmart@gmail.com>
# SPDX-FileCopyrightText: 2023 Volker Krause <vkrause@kde.org>
# SPDX-FileCopyrightText: 2025 Carl Schwan <carl@carlschwan.eu>
# SPDX-License-Identifier: BSD-2-Clause

include(ExternalProject)

function(kirigami_package_breeze_icons)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "" "OVERRIDE_REPOSITORY;OVERRIDE_DIR" "ICONS")

    if(NOT ARG_ICONS)
        message(FATAL_ERROR "No ICONS argument given to kirigami_package_breeze_icons")
    endif()

    if(NOT ANDROID)
        return() # not needed on other platforms
    endif()

    #include icons used by Kirigami components themselves
    set(ARG_ICONS ${ARG_ICONS}
        application-exit
        application-menu-symbolic
        dialog-close
        dialog-error
        dialog-information
        dialog-positive
        dialog-warning
        edit-clear
        edit-clear-locationbar-ltr
        edit-clear-locationbar-rtl
        edit-copy
        edit-delete-remove
        edit-delete-remove-symbolic
        edit-entry-symbolic
        edit-select-all-symbolic
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
        help-contextual-symbolic
        list-add-symbolic
        mail-sent
        open-menu-symbolic
        open-link-symbolic
        open-link-symbolic-rtl
        overflow-menu-left
        overflow-menu-right
        overflow-menu
        overflow-menu-symbolic
        password-show-off
        password-show-on
        process-working-symbolic
        search
        tag-symbolic
        tools-report-bug
        user
        view-left-new
        view-right-new
        view-left-close
        view-right-close
        window-close
        window-close-symbolic
    )

    function(_find_breeze_icon icon icon_dir found)
        set(_found FALSE)
        foreach(_size 48 32 24 22 16 12)
            SET(path "")
            file(GLOB_RECURSE path "${icon_dir}/*/${_size}/${icon}.svg")
            if (path STREQUAL "")
                continue()
            endif()

            list(LENGTH path _count_paths)
            if (_count_paths GREATER 1)
                message(WARNING "Found more than one version of '${icon}': ${path}")
            endif()
            list(GET path 0 path)

            get_filename_component(realpath "${path}" REALPATH)
            if (EXISTS "${realpath}")
                install(FILES "${realpath}" DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami/breeze-internal/icons/${_size}
                    RENAME "${icon}.svg")
                set(_found TRUE)
            endif()
        endforeach()
        set(${found} ${_found} PARENT_SCOPE)
    endfunction()

    if(ARG_OVERRIDE_REPOSITORY AND ARG_OVERRIDE_DIR)
        message(FATAL_ERROR "Specify only one of OVERRIDE_REPOSITORY and OVERRIDE_DIR")
    endif()

    if(ARG_OVERRIDE_DIR)
        file(REAL_PATH "${ARG_OVERRIDE_DIR}" _override_dir EXPAND_TILDE)
        if(NOT IS_DIRECTORY "${_override_dir}")
            message(FATAL_ERROR "OVERRIDE_DIR does not point to an existing directory: ${ARG_OVERRIDE_DIR}")
        endif()
    elseif(ARG_OVERRIDE_REPOSITORY)
        string(SHA256 _override_id "${ARG_OVERRIDE_REPOSITORY}")
        set(_override_dir "${CMAKE_BINARY_DIR}/kirigami-icons/${_override_id}")
        if(NOT EXISTS "${_override_dir}")
            find_package(Git REQUIRED)
            execute_process(
                COMMAND "${GIT_EXECUTABLE}" clone --depth 1 -- "${ARG_OVERRIDE_REPOSITORY}" "${_override_dir}"
                COMMAND_ERROR_IS_FATAL ANY
            )
        endif()
    endif()

    if(_override_dir)
        if(IS_DIRECTORY "${_override_dir}/icons")
            string(APPEND _override_dir "/icons")
        endif()
        message(STATUS "Using icon overrides from: ${_override_dir}")
    endif()

    if (BREEZEICONS_DIR AND NOT EXISTS ${BREEZEICONS_DIR})
        message(FATAL_ERROR "BREEZEICONS_DIR variable does not point to existing dir: \"${BREEZEICONS_DIR}\"")
    endif()

    # Resolve relative paths and symlinks in the Breeze checkout path.
    if (BREEZEICONS_DIR)
        file(REAL_PATH "${BREEZEICONS_DIR}" _BREEZEICONS_DIR EXPAND_TILDE)
    endif()

    #FIXME: this is a terrible hack
    if(NOT _BREEZEICONS_DIR)
        file(REAL_PATH "${CMAKE_BINARY_DIR}/breeze-icons/src/breeze-icons" _BREEZEICONS_DIR EXPAND_TILDE)

        # replacement for ExternalProject_Add not yet working
        # first time config?
        if (NOT EXISTS ${_BREEZEICONS_DIR})
            find_package(Git)
            execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 https://invent.kde.org/frameworks/breeze-icons.git ${_BREEZEICONS_DIR})
        endif()
    endif()

    message (STATUS "Found external breeze icons:")
    foreach(_iconName ${ARG_ICONS})
        set(_overridden FALSE)
        if(_override_dir)
            _find_breeze_icon("${_iconName}" "${_override_dir}" _overridden)
        endif()
        if(NOT _overridden)
            _find_breeze_icon("${_iconName}" "${_BREEZEICONS_DIR}/icons" _found)
        endif()
    endforeach()

    #generate an index.theme that qiconloader can understand
    file(WRITE ${CMAKE_BINARY_DIR}/index.theme "[Icon Theme]\nName=Breeze\nDirectories=icons/12,icons/16,icons/22,icons/24,icons/32,icons/48,icons\nFollowsColorScheme=true\n[icons/12]\nSize=12\nType=Fixed\n[icons/16]\nSize=16\nType=Fixed\n[icons/22]\nSize=22\nType=Fixed\n[icons/24]\nSize=24\nType=Fixed\n[icons/32]\nSize=32\nType=Fixed\n[icons/48]\nSize=48\nType=Fixed\n[icons]\nSize=32\nType=Scalable\n")
    install(FILES ${CMAKE_BINARY_DIR}/index.theme DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami/breeze-internal/)
endfunction()
