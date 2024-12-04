cmake_minimum_required(VERSION 3.16)

set(KF_VERSION "6.14.0") # handled by release scripts
set(KF_DEP_VERSION "6.13.0") # handled by release scripts

project(kirigami2 VERSION ${KF_VERSION})

set(REQUIRED_QT_VERSION 6.7.0)

################# Disallow in-source build #################

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "kirigami requires an out of source build. Please create a separate build directory and run 'cmake path_to_kirigami [options]' there.")
endif()

option(BUILD_SHARED_LIBS "Build a shared module" ON)
option(DESKTOP_ENABLED "Build and install The Desktop style" ON)
option(BUILD_EXAMPLES "Build and install examples" OFF)
option(UBUNTU_TOUCH "Build for Ubuntu Touch" OFF)
if(DEFINED STATIC_LIBRARY)
    message(FATAL_ERROR "Use the BUILD_SHARED_LIBS=OFF option to build a static library, STATIC_LIBRARY is no longer a supported option")
endif()
find_package(ECM 6.13.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

if (NOT ${BUILD_SHARED_LIBS})
    # Examples are not supported when building a static library, so force them
    # to OFF.
    set(BUILD_EXAMPLES OFF)
endif()

include(FeatureSummary)
include(KDEInstallDirs)
find_package(Qt6 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Core Quick Gui Svg QuickControls2 Concurrent ShaderTools)

if (Qt6Gui_VERSION VERSION_GREATER_EQUAL "6.10.0")
    find_package(Qt6GuiPrivate ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE)
endif()

if (BUILD_TESTING)
    find_package(Qt6QuickTest ${REQUIRED_QT_VERSION} CONFIG QUIET)
endif()
get_target_property(QtGui_Enabled_Features Qt6::Gui QT_ENABLED_PUBLIC_FEATURES)
if(QtGui_Enabled_Features MATCHES "opengl")
    set(HAVE_QTGUI_OPENGL 1)
else()
    set(HAVE_QTGUI_OPENGL 0)
endif()
add_feature_info(QtGuiOpenGL HAVE_QTGUI_OPENGL "QtGui built with support for OpenGL")
set(CMAKE_AUTOMOC ON)
set(AUTOMOC_MOC_OPTIONS -Muri=org.kde.kirigami)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

if(NOT BUILD_SHARED_LIBS)
    add_definitions(-DKIRIGAMI_BUILD_TYPE_STATIC)
    add_definitions(-DQT_PLUGIN)
    add_definitions(-DQT_STATICPLUGIN=1)
endif()

################# set KDE specific information #################
# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set_package_properties(ECM PROPERTIES TYPE REQUIRED DESCRIPTION "Extra CMake Modules." URL "https://commits.kde.org/extra-cmake-modules")

include(ECMGenerateExportHeader)
include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(CMakePackageConfigHelpers)
include(ECMPoQmTools)
include(ECMFindQmlModule)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDEGitCommitHooks)
include(ECMQtDeclareLoggingCategory)
include(KDEFrameworkCompilerSettings NO_POLICY_SCOPE)
include(KDEPackageAppTemplates)
include(ECMQmlModule)
include(ECMDeprecationSettings)
include(ECMGenerateQDoc)

set(CMAKECONFIG_INSTALL_DIR "${KDE_INSTALL_CMAKEPACKAGEDIR}/KF6Kirigami")

ecm_setup_version(PROJECT
    VARIABLE_PREFIX KIRIGAMI
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/kirigami_version.h"
    PACKAGE_VERSION_FILE "${CMAKE_CURRENT_BINARY_DIR}/KF6KirigamiConfigVersion.cmake"
    SOVERSION 6
)

ecm_setup_version(PROJECT
    VARIABLE_PREFIX KIRIGAMI
    PACKAGE_VERSION_FILE "${CMAKE_CURRENT_BINARY_DIR}/KF6Kirigami2ConfigVersion.cmake"
    SOVERSION 6
)

# shall we use DBus?
# enabled per default on Linux & BSD systems
set(USE_DBUS_DEFAULT OFF)
if(UNIX AND NOT APPLE AND NOT ANDROID AND NOT HAIKU)
    set(USE_DBUS_DEFAULT ON)
endif()
option(USE_DBUS "Build components using DBus" ${USE_DBUS_DEFAULT})
if(USE_DBUS)
    find_package(Qt6DBus ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE)
    set(WITH_DBUS ON)
    add_definitions(-DKIRIGAMI_ENABLE_DBUS)
endif()

find_package(OpenMP)
set_package_properties(OpenMP
    PROPERTIES DESCRIPTION "Multi-platform shared-memory parallel programming in C/C++ and Fortran"
    TYPE OPTIONAL
    PURPOSE "Accelerates palette generation in Kirigami.ImageColors"
)
if(OpenMP_CXX_FOUND)
    set(HAVE_OpenMP TRUE)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif()

include_directories("${CMAKE_CURRENT_BINARY_DIR}")
configure_file(config-OpenMP.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-OpenMP.h)

if (UBUNTU_TOUCH)
    add_definitions(-DUBUNTU_TOUCH)
endif()

ecm_set_disabled_deprecation_versions(
    QT 6.2
    KF 6.12.0
)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # link time optimization has been observed to break colors. Force-disable it.
    # Before undoing this make double sure the lockscreen
    # and logout screen are correctly colored in light/dark mode!
    add_compile_options("-fno-lto")
endif()

add_subdirectory(src)
if (NOT ANDROID)
    add_subdirectory(templates)
endif()

if (BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

if (BUILD_TESTING)
    add_subdirectory(autotests)
endif()

configure_package_config_file(
    "KF6KirigamiConfig.cmake.in"
    "KF6KirigamiConfig.cmake"
    INSTALL_DESTINATION  ${CMAKECONFIG_INSTALL_DIR}
    PATH_VARS CMAKE_INSTALL_PREFIX
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/KF6KirigamiConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/KF6KirigamiConfigVersion.cmake"
    "${CMAKE_CURRENT_SOURCE_DIR}/KF6KirigamiMacros.cmake"
    DESTINATION "${CMAKECONFIG_INSTALL_DIR}"
    COMPONENT Devel
)

configure_package_config_file(
    "KF6Kirigami2Config.cmake.in"
    "KF6Kirigami2Config.cmake"
    INSTALL_DESTINATION "${KDE_INSTALL_CMAKEPACKAGEDIR}/KF6Kirigami2"
    PATH_VARS CMAKE_INSTALL_PREFIX
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/KF6Kirigami2Config.cmake
    "${CMAKE_CURRENT_BINARY_DIR}/KF6Kirigami2ConfigVersion.cmake"
    DESTINATION ${KDE_INSTALL_CMAKEPACKAGEDIR}/KF6Kirigami2
    COMPONENT Devel
)

ecm_install_po_files_as_qm(poqm)

include(ECMFeatureSummary)
ecm_feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

configure_file(qmllint.ini.in ${CMAKE_SOURCE_DIR}/.qmllint.ini)

kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
