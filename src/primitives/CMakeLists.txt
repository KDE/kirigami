
add_library(KirigamiPrimitives)
ecm_add_qml_module(KirigamiPrimitives URI "org.kde.kirigami.primitives"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiPrimitives
    DEPENDENCIES QtQuick org.kde.kirigami.platform
)

target_sources(KirigamiPrimitives PRIVATE
    icon.cpp
    icon.h
    shadowedrectangle.cpp
    shadowedrectangle.h
    shadowedtexture.cpp
    shadowedtexture.h

    scenegraph/shadernode.cpp
    scenegraph/shadernode.h
    scenegraph/shadermaterial.cpp
    scenegraph/shadermaterial.h
    scenegraph/softwarerectanglenode.cpp
    scenegraph/softwarerectanglenode.h
    scenegraph/texturecache.cpp
    scenegraph/texturecache.h
)

ecm_target_qml_sources(KirigamiPrimitives SOURCES
    Separator.qml
    ShadowedImage.qml
)

set_target_properties(KirigamiPrimitives PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiPrimitives"
)

target_include_directories(KirigamiPrimitives PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

target_link_libraries(KirigamiPrimitives PRIVATE Qt6::Quick KirigamiPlatform)

if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    set(_extra_options DEBUGINFO)
else()
    set(_extra_options PRECOMPILE OPTIMIZED)
endif()

include(shaders.cmake)

ecm_finalize_qml_module(KirigamiPrimitives EXPORT KirigamiTargets)

install(TARGETS KirigamiPrimitives EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
