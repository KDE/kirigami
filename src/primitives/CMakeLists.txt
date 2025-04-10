
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
    scenegraph/texturecache.cpp
    scenegraph/texturecache.h
    scenegraph/managedtexturenode.cpp
    scenegraph/managedtexturenode.h
    scenegraph/paintedrectangleitem.cpp
    scenegraph/paintedrectangleitem.h
    scenegraph/shadowedborderrectanglematerial.cpp
    scenegraph/shadowedborderrectanglematerial.h
    scenegraph/shadowedbordertexturematerial.cpp
    scenegraph/shadowedbordertexturematerial.h
    scenegraph/shadowedrectanglematerial.cpp
    scenegraph/shadowedrectanglematerial.h
    scenegraph/shadowedrectanglenode.cpp
    scenegraph/shadowedrectanglenode.h
    scenegraph/shadowedtexturematerial.cpp
    scenegraph/shadowedtexturematerial.h
    scenegraph/shadowedtexturenode.cpp
    scenegraph/shadowedtexturenode.h
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

qt6_add_shaders(KirigamiPrimitives "shadowed_rectangle"
    BATCHABLE
    PREFIX "/qt/qml/org/kde/kirigami/primitives/shaders"
    FILES
        shaders/shadowedrectangle.vert
        shaders/shadowedrectangle.frag
    OUTPUTS
        shadowedrectangle.vert.qsb
        shadowedrectangle.frag.qsb
    ${_extra_options}
    OUTPUT_TARGETS _shadowed_rectangle_targets
)

qt6_add_shaders(KirigamiPrimitives "shadowed_border_rectangle"
    BATCHABLE
    PREFIX "/qt/qml/org/kde/kirigami/primitives/shaders"
    FILES
        shaders/shadowedrectangle.vert
        shaders/shadowedrectangle.frag
    OUTPUTS
        shadowedborderrectangle.vert.qsb
        shadowedborderrectangle.frag.qsb
    DEFINES
        ENABLE_BORDER=1
    ${_extra_options}
    OUTPUT_TARGETS _shadowed_border_rectangle_targets
)

qt6_add_shaders(KirigamiPrimitives "shadowed_texture"
    BATCHABLE
    PREFIX "/qt/qml/org/kde/kirigami/primitives/shaders"
    FILES
        shaders/shadowedrectangle.vert
        shaders/shadowedrectangle.frag
    OUTPUTS
        shadowedtexture.vert.qsb
        shadowedtexture.frag.qsb
    DEFINES
        ENABLE_TEXTURE=1
    ${_extra_options}
    OUTPUT_TARGETS _shadowed_texture_targets
)

qt6_add_shaders(KirigamiPrimitives "shadowed_border_texture"
    BATCHABLE
    PREFIX "/qt/qml/org/kde/kirigami/primitives/shaders"
    FILES
        shaders/shadowedrectangle.vert
        shaders/shadowedrectangle.frag
    OUTPUTS
        shadowedbordertexture.vert.qsb
        shadowedbordertexture.frag.qsb
    DEFINES
        ENABLE_BORDER=1
        ENABLE_TEXTURE=1
    ${_extra_options}
    OUTPUT_TARGETS _shadowed_border_texture_targets
)

ecm_finalize_qml_module(KirigamiPrimitives EXPORT KirigamiTargets)

install(TARGETS
    KirigamiPrimitives
    ${_shadowed_rectangle_targets}
    ${_shadowed_border_rectangle_targets}
    ${_shadowed_texture_targets}
    ${_shadowed_border_texture_targets}
    EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS}
)
