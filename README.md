# Kirigami

QtQuick plugins to build user interfaces following the [KDE Human Interface Guidelines](https://develop.kde.org/hig/).

## Introduction

Kirigami is a set of [QtQuick](https://doc.qt.io/qt-6/qtquick-index.html) components for building adaptable user interfaces based on [QtQuick Controls 2](https://doc.qt.io/qt-6/qtquickcontrols-index.html). Kirigami makes it easy to create applications that look and feel great on [Plasma Mobile](https://plasma-mobile.org/), Desktop Linux, Android, MacOS, and Windows.

The API can be found in the [KDE API Reference website](https://api.kde.org/kirigami-index.html) and a Kirigami tutorial is available in the [KDE Developer Platform](https://develop.kde.org/docs/getting-started/kirigami/).

We also provide [Kirigami Gallery](https://invent.kde.org/sdk/kirigami-gallery) to showcase most Kirigami components.

## Building Kirigami

After installing `extra-cmake-modules` (ECM) and the necessary Qt6 development libraries, run:

```bash
git clone https://invent.kde.org/frameworks/kirigami.git
cd kirigami
cmake -B build/ -DCMAKE_INSTALL_PREFIX=/path/where/kirigami/will/be/installed
cmake --build build/
cmake --install build/
```

If you compiled and installed ECM yourself, you will need to add it to your PATH to compile Kirigami with it, as ECM does not provide its own `prefix.sh` file:

```bash
PATH=/path/to/the/ecm/installation/usr/ cmake -B build/ -DCMAKE_INSTALL_PREFIX=/path/where/kirigami/will/be/installed
cmake --build build/
cmake --install build/
```

Alternatively, we recommend you use [kdesrc-build](https://community.kde.org/Get_Involved/development#Setting_up_the_development_environment) to build extra-cmake-modules and Kirigami together.

The provided Kirigami example can be built and run with:

```bash
cmake -B build/ -DBUILD_EXAMPLES=ON
cmake --build build/
./build/bin/applicationitemapp
```

And the remaining examples containing only single QML files in the `examples/` folder can be viewed using `qml <filename.qml>` or `qmlscene <filename.qml>`.

# Using a self-compiled Kirigami in your application

To compile your application and link a self-compiled build of Kirigami to it, run:

```bash
source path/to/kirigami/build/prefix.sh
```

And then compile your application as usual.

# Build your Android application and ship it with Kirigami

1) Build Kirigami

You will need to compile Qt for Android or use the [Qt Installer](https://www.qt.io/download-open-source) to install it, in addition to the Android SDK and NDK. After that, run:

```bash
cmake -B build/ \
    -DCMAKE_TOOLCHAIN_FILE=/usr/share/ECM/toolchain/Android.cmake \
    -DCMAKE_PREFIX_PATH=/path/to/Qt5.15.9/5.15/android_armv7/ \
    -DCMAKE_INSTALL_PREFIX=/path/where/kirigami/will/be/installed/ \
    -DECM_DIR=/usr/share/ECM/cmake

cmake --build build/
cmake --install build/
```

2) Build your application

This guide assumes that you build your application with CMake and use [Extra CMake Modules (ECM)](https://api.kde.org/ecm/) from KDE frameworks.

Replace `$yourapp` with the actual name of your application:

```bash
cmake -B build/ \
    -DCMAKE_TOOLCHAIN_FILE=/usr/share/ECM/toolchain/Android.cmake \
    -DQTANDROID_EXPORTED_TARGET=$yourapp \
    -DANDROID_APK_DIR=../path/to/yourapp/ \
    -DCMAKE_PREFIX_PATH=/path/to/Qt5.15.9/5.15/android_armv7/ \
    -DCMAKE_INSTALL_PREFIX=/path/where/yourapp/will/be/installed/

cmake --build build/
cmake --install build/
cmake --build build/ --target create-apk-$yourapp
```

Note: `-DCMAKE_INSTALL_PREFIX` directory should be the same as where Kirigami was installed, since you need to create an apk package that contains both the Kirigami build and the build of your application.

# Adding new components

When adding new components to Kirigami the following requirements must be fulfilled:

- Must fit the vision of Kirigami
- Must be documented with appropriate API documentation
- Must come with an autotest
- Must come with a corresponding change that adds it to kirigami-gallery
- Must come with one or more changes that makes use of it in an application
- Must be reviewed so that it does not expose unnecessary API and implementation details (e.g. the base component)
