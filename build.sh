#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

external="$PWD/../3rdparty"

#--------------------------------------------------------------------------------------------------

MinGW_version="7.3.0"

Qt_versionA="5.12.3"
Qt_versionB="5.12"

Qt="qt-everywhere-src-$Qt_versionA"

#Qt_url="http://download.qt.io/official_releases/qt/$Qt_versionB/$Qt_versionA/single/$Qt.tar.xz"

# NOTE: That mirror seems faster than the official one.
Qt_url="http://ftp1.nluug.nl/languages/qt/archive/qt/$Qt_versionB/$Qt_versionA/single/$Qt.tar.xz"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 ] || [ $1 != "win32" -a $1 != "win64" -a $1 != "linux" -a $1 != "macOS" ]; then

    echo "Usage: build <win32 | win64 | linux | macOS>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $1 = "win32" -o $1 = "win64" ]; then

    windows=true

    external="$external/$1"
else
    windows=false
fi

#--------------------------------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------------------------------

if [ $1 = "linux" ]; then

    apt-get -y install build-essential qtdeclarative5-dev curl xz-utils python
fi

#--------------------------------------------------------------------------------------------------
# Download
#--------------------------------------------------------------------------------------------------

echo ""
echo "DOWNLOADING Qt"
echo $Qt_url

curl -L -o Qt.tar.xz --retry 3 $Qt_url

#--------------------------------------------------------------------------------------------------
# Qt
#--------------------------------------------------------------------------------------------------

echo "EXTRACTING Qt"

# NOTE Windows: We need to use 7z otherwise it seems to freeze Azure.
if [ $windows = true ]; then

    7z x Qt.tar.xz
    7z x Qt.tar
else
    tar -xf Qt.tar.xz
fi

#--------------------------------------------------------------------------------------------------
# Path
#--------------------------------------------------------------------------------------------------

if [ $windows = true ]; then

    # NOTE Windows: We are building with our own MinGW.
    PATH="$external/MinGW/$MinGW_version/bin:$PATH"
fi

#--------------------------------------------------------------------------------------------------
# Configure
#--------------------------------------------------------------------------------------------------

echo "CONFIGURING Qt"

path=deploy/Qt/$Qt_versionA

mkdir -p $path

cd $Qt

if [ $windows = true ]; then

    ./configure -prefix $path \
                -platform win32-g++ \
                -release \
                -opensource \
                -confirm-license \
                -nomake examples \
                -nomake tests \
                -skip qtdoc \
                -opengl desktop \
                -verbose
else
    ./configure -prefix $path \
                -release \
                -opensource \
                -confirm-license \
                -nomake examples \
                -nomake tests \
                -skip qtdoc \
                -verbose
fi

#--------------------------------------------------------------------------------------------------
# Build
#--------------------------------------------------------------------------------------------------

echo "BUILDING Qt"

if [ $windows = true ]; then

    mingw32-make
else
    make
fi

#--------------------------------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------------------------------

echo "INSTALLING Qt"

if [ $windows = true ]; then

    mingw32-make install
else
    make install
fi

#--------------------------------------------------------------------------------------------------
# Deploy
#--------------------------------------------------------------------------------------------------

#cd ..
#
#path=deploy/Qt/$Qt_versionA
#
#mkdir -p $path
#
#if [ $windows = true ]; then
#
#    mv $Qt/* $path
#
#elif [ $1 = "macOS" ]; then
#
#    mv /usr/local/Qt-$Qt_versionA/* $path
#
#elif [ $1 = "linux" ]; then
#
#    mv /usr/local/Qt-$Qt_versionA/* $path
#fi
