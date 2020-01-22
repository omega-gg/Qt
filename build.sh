#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

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
else
    windows=false
fi

#--------------------------------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------------------------------

if [ $windows = true ]; then

    curl -L -o directX.exe https://download.microsoft.com/download/A/E/7/AE743F1F-632B-4809-87A9-AA1BB3458E31/DXSDK_Jun10.exe

    ./directX /silent

elif [ $1 = "linux" ]; then

    apt-get -y install build-essential qtdeclarative5-dev curl xz-utils python
fi

#--------------------------------------------------------------------------------------------------
# Download
#--------------------------------------------------------------------------------------------------

echo "DOWNLOAD Qt"

echo $Qt_url

curl -L -o Qt.tar.xz $Qt_url

#--------------------------------------------------------------------------------------------------
# Qt
#--------------------------------------------------------------------------------------------------

echo "EXTRACT Qt"

# NOTE Windows: We need to use 7z otherwise it seems to freeze Azure.
if [ $windows = true ]; then

    7z x Qt.tar.xz
    7z x Qt.tar
else
    tar -xf Qt.tar.xz
fi

#--------------------------------------------------------------------------------------------------
# Configure
#--------------------------------------------------------------------------------------------------

echo "CONFIGURE Qt"

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

#--------------------------------------------------------------------------------------------------
# Build
#--------------------------------------------------------------------------------------------------

echo "BUILD Qt"

if [ $windows = true ]; then

    cp -r $(pwd)/qtbase/src/3rdparty/angle/include/* $(pwd)/qtbase/include

    ls -la $(pwd)/qtbase/include

    # NOTE windows: This is required for building qopengl
    #PATH="$(pwd)/qtbase/include/QtANGLE:$PATH"

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

cd ../deploy

path=Qt/$Qt_versionA

mkdir -p $path

if [ $windows = true ]; then

    mv $Qt/* $path

elif [ $1 = "macOS" ]; then

    mv /usr/local/Qt-$Qt_versionA/* $path

elif [ $1 = "linux" ]; then

    mv /usr/local/Qt-$Qt_versionA/* $path
fi
