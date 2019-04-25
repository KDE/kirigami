# Kirigami

QtQuick plugins to build user interfaces based on the KDE UX guidelines

## Introduction

Kirigami is a set of QtQuick components at the moment targeted for mobile use (in the future desktop as well) targeting both Plasma Mobile and Android. It’s not a whole set of components, all the “Primitive” ones like buttons and textboxes are a job for QtQuickControls (soon QtQuickControls2) but it’s a set of high level components to make the creation of applications that look and feel great on mobile as well as desktop devices and follow the Kirigami Human Interface Guidelines.

## Build examples to desktop
Build all examples available
```sh
mkdir build
cd build
cmake .. -DBUILD_EXAMPLES=ON
make
```
Than, you can run:
```sh
./examples/applicationitemapp/applicationitemapp
# or
./examples/galleryapp/kirigami2gallery
```

## Build the gallery example app on Android:
Make sure to install **android-sdk**, **android-ndk** and **android-qt5-arch**, where **arch** should be the same architecture that you aim to deploy.
```sh
mkdir build
cd build
cmake .. \
    -DQTANDROID_EXPORTED_TARGET=kirigami2gallery \
    -DBUILD_EXAMPLES=on \
    -DANDROID_APK_DIR=../examples/galleryapp \
    -DECM_DIR=/path/to/share/ECM/cmake \
    -DCMAKE_TOOLCHAIN_FILE=/usr/share/ECM/toolchain/Android.cmake \
    -DECM_ADDITIONAL_FIND_ROOT_PATH=/path/to/Qt5.7.0/5.7/{arch} \
    -DCMAKE_PREFIX_PATH=/path/to/Qt5.7.0/5.7/{arch}/path/to/Qt5Core \
    -DANDROID_NDK=/path/to/Android/Sdk/ndk-bundle \
    -DANDROID_SDK_ROOT=/path/to/Android/Sdk/ \
    -DANDROID_SDK_BUILD_TOOLS_REVISION=26.0.2 \
    -DCMAKE_INSTALL_PREFIX=/path/to/dummy/install/prefix
```

You need a `-DCMAKE_INSTALL_PREFIX` to somewhere in your home, but using an absolute path.

If you have a local checkout of the breeze-icons repo, you can avoid the cloning of the build dir
by passing also `-DBREEZEICONS_DIR=/path/to/existing/sources/of/breeze-icons`

```
make create-apk-kirigami2gallery
```

`./kirigami2gallery_build_apk/build/outputs/apk/kirigami2gallery_build_apk-debug.apk` will be generated

To directly install on a phone:
```
adb install -r ./kirigami2gallery_build_apk/build/outputs/apk/kirigami2gallery_build_apk-debug.apk
```
To perform this, your device need to be configureted with `USB debugging` and `install via USB` in `Developer options`.

> Some ambient variables must be set before the process: `ANDROID_NDK`, `ANDROID_SDK_ROOT`, `Qt5_android` and `JAVA_HOME`
```
export ANDROID_NDK=/path/to/android-ndk
export ANDROID_SDK_ROOT=/path/to/android-sdk
export Qt5_android=/path/to/android-qt5/5.7.0/{arch}
export PATH=$ANDROID_SDK_ROOT/platform-tools/:$PATH
# adapt the following path to your ant installation
export ANT=/usr/bin/ant
export JAVA_HOME=/path/to/lib/jvm/java-8-openjdk/
```
# Build on your application Android, ship it together Kirigami

1) Build kirigami


use the same procedure mentioned above (but without BUILD_EXAMPLES switch

cd into kirigami sources directory.

```sh
mkdir build
cd build

cmake ..  \
    -DCMAKE_TOOLCHAIN_FILE=/path/to/share/ECM/toolchain/Android.cmake\
    -DCMAKE_PREFIX_PATH=/path/to/Qt5.7.0/5.7/android_armv7/\
    -DCMAKE_INSTALL_PREFIX=/path/to/dummy/install/prefix\
    -DECM_DIR=/path/to/share/ECM/cmake

make
make install
```
(note, omit the make create-apk-kirigami2gallery step)

2) Build your application

This guide assumes you build your application with CMake and use Extra-cmake-modules from KDE frameworks.


cd into your application sources directory.

```sh
mkdir build
cd build

cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=/path/to/share/ECM/toolchain/Android.cmake \
    -DQTANDROID_EXPORTED_TARGET=yourapp \
    -DANDROID_APK_DIR=../examples/galleryapp/ \
    -DCMAKE_PREFIX_PATH=/path/to/Qt5.7.0/5.7/android_armv7/ \
    -DCMAKE_INSTALL_PREFIX=/path/to/dummy/install/prefix
```

Note, `-DCMAKE_INSTALL_PREFIX` folder will be the same as where kirigami was installed, since you need to create an apk package that contains both the kirigami build and the build of your application.

```sh
make
make install
make create-apk-yourapp
```

where make create-apk-yourapp dependes from the actual name of your application

# Build a QMake-based application

* Base upon the example in examples/minimalqmake
* on android, it builds it statically, on desktop systems it uses the one distribution provided (static linking mode may be useful for other systems such as iOS or Windows)
* in order to have static linking working, clone kirigami.git and breeze-icons.git under the 3rdparty folder
* in your main.cpp you'll have, only on android KirigamiPlugin::getInstance().registerTypes(); which will make the import work
* qtcreator should be able to do deployment on android out of the box

