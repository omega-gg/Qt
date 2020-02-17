#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

external="$PWD/../3rdparty"

#--------------------------------------------------------------------------------------------------

MinGW_version="7.3.0"

Qt_versionA="5.14.1"
Qt_versionB="5.14"

Qt="qt-everywhere-src-$Qt_versionA"

#Qt_url="http://download.qt.io/official_releases/qt/$Qt_versionB/$Qt_versionA/single/$Qt.tar.xz"

# NOTE: That mirror seems faster than the official one.
Qt_url="http://ftp1.nluug.nl/languages/qt/archive/qt/$Qt_versionB/$Qt_versionA/single/$Qt.tar.xz"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 ] || [ $1 != "win32" -a $1 != "win64" -a $1 != "macOS" -a $1 != "linux" ]; then

    echo "Usage: build <win32 | win64 | macOS | linux>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $1 = "win32" -o $1 = "win64" ]; then

    os="windows"

    external="$external/$1"
else
    os="default"
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

echo "CLEANING"

rm -rf deploy
mkdir  deploy
touch  deploy/.gitignore

#--------------------------------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------------------------------

if [ $1 = "linux" ]; then

    sudo apt-get -y install build-essential qtdeclarative5-dev curl xz-utils python
fi

#--------------------------------------------------------------------------------------------------
# Download
#--------------------------------------------------------------------------------------------------

echo ""
echo "DOWNLOADING Qt"
echo $Qt_url

curl --retry 3 -L -o Qt.tar.xz $Qt_url

#--------------------------------------------------------------------------------------------------
# Qt
#--------------------------------------------------------------------------------------------------

echo "EXTRACTING Qt"

# NOTE Windows: We need to use 7z otherwise it seems to freeze Azure.
if [ $os = "windows" ]; then

    7z x Qt.tar.xz > nul
    7z x Qt.tar    > nul
else
    tar -xf Qt.tar.xz
fi

#--------------------------------------------------------------------------------------------------
# Path
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    # NOTE Windows: We are building with our own MinGW.
    PATH="$external/MinGW/$MinGW_version/bin:$PATH"
fi

#--------------------------------------------------------------------------------------------------
# Configure
#--------------------------------------------------------------------------------------------------

echo "CONFIGURING Qt"

path="$PWD/deploy/Qt/$Qt_versionA"

mkdir -p $path

cd $Qt

if [ $os = "windows" ]; then

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

if [ $os = "windows" ]; then

    mingw32-make
else
    make
fi

#--------------------------------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------------------------------

echo "INSTALLING Qt"

if [ $os = "windows" ]; then

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
#if [ $os = "windows" ]; then
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
