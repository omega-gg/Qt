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

Qt_url="http://download.qt.io/official_releases/qt/$Qt_versionB/$Qt_versionA/single/$Qt.tar.xz"

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

    # NOTE Windows: We are building with our own MinGW.
    #PATH="$external/MinGW/$MinGW_version:$external/MinGW/$MinGW_version/bin:$external/MinGW/$MinGW_version/lib:$PWD/$Qt/gnuwin32/bin:$PATH"

    #echo $PATH

    #echo "MinGW"
    #ls -la $external/MinGW/$MinGW_version
    #echo "MinGW bin"
    #ls -la $external/MinGW/$MinGW_version/bin
    #echo "MinGW lib"
    #ls -la $external/MinGW/$MinGW_version/lib

    #cp -r $external/MinGW/$MinGW_version/include/GLES2 $external/MinGW/$MinGW_version/i686-w64-mingw32/include

    #cp $external/MinGW/$MinGW_version/lib/liblibEGL.a    $external/MinGW/$MinGW_version/i686-w64-mingw32/lib
    #cp $external/MinGW/$MinGW_version/lib/liblibGLESv2.a $external/MinGW/$MinGW_version/i686-w64-mingw32/lib

    #echo "i686-w64-mingw32/include"
    #ls -la $external/MinGW/$MinGW_version/i686-w64-mingw32/include

    #echo "i686-w64-mingw32/lib"
    #ls -la $external/MinGW/$MinGW_version/i686-w64-mingw32/lib

    #echo "gcc version"
    #gcc --version
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

curl -L -o Qt.tar.xz $Qt_url

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
    PATH="$external/MinGW/$MinGW_version/bin:$PWD/$Qt/gnuwin32/bin:$PATH"

    cp -r $Qt/qtbase/src/3rdparty/angle/include/* $external/MinGW/$MinGW_version/i686-w64-mingw32/include

    cp $external/MinGW/$MinGW_version/lib/liblibEGL.a    $external/MinGW/$MinGW_version/i686-w64-mingw32/lib
    cp $external/MinGW/$MinGW_version/lib/liblibGLESv2.a $external/MinGW/$MinGW_version/i686-w64-mingw32/lib

    echo "i686-w64-mingw32/include"
    ls -la $external/MinGW/$MinGW_version/i686-w64-mingw32/include

    echo "i686-w64-mingw32/lib"
    ls -la $external/MinGW/$MinGW_version/i686-w64-mingw32/lib

    echo "gcc version"
    gcc --version
fi

#--------------------------------------------------------------------------------------------------
# Configure
#--------------------------------------------------------------------------------------------------

echo "CONFIGURING Qt"

cd $Qt

if [ $windows = true ]; then

    ./configure -platform win32-g++ \
                -release \
                -opensource \
                -confirm-license \
                -nomake examples \
                -nomake tests \
                -skip qtdoc \
                -verbose
else
    ./configure -release \
                -opensource \
                -confirm-license \
                -nomake examples \
                -nomake tests \
                -skip qtdoc \
                -verbose
fi

# TEMP
exit 1

#--------------------------------------------------------------------------------------------------
# Build
#--------------------------------------------------------------------------------------------------

echo "BUILDING Qt"

if [ $windows = true ]; then

    #----------------------------------------------------------------------------------------------
    # NOTE windows: This is required for building with OpenGL ES

    cp -r $PWD/qtbase/src/3rdparty/angle/include/* $PWD/qtbase/include

    ls -la $PWD/qtbase/include

    #----------------------------------------------------------------------------------------------

    # NOTE windows: This is required for building qopengl
    #PATH="$PWD/qtbase/include/QtANGLE:$PATH"

    mingw32-make
else
    make
fi

#--------------------------------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------------------------------

if [ $1 = "macOS" ] || [ $1 = "linux" ]; then

    make install
fi

#--------------------------------------------------------------------------------------------------
# Deploy
#--------------------------------------------------------------------------------------------------

cd ..

path=deploy/Qt/$Qt_versionA

mkdir -p $path

if [ $windows = true ]; then

    mv $Qt/* $path

elif [ $1 = "macOS" ]; then

    mv /usr/local/Qt-$Qt_versionA/* $path

elif [ $1 = "linux" ]; then

    mv /usr/local/Qt-$Qt_versionA/* $path
fi
