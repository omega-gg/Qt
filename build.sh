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
# Install
#--------------------------------------------------------------------------------------------------

if [ $1 = "linux" ]; then

    apt-get -y install build-essential qtdeclarative5-dev curl xz-utils
fi

#--------------------------------------------------------------------------------------------------
# Download
#--------------------------------------------------------------------------------------------------

echo "DOWNLOAD Qt"

echo $Qt_url

curl -L -o Qt.tar.gz $Qt_url

#--------------------------------------------------------------------------------------------------
# Qt
#--------------------------------------------------------------------------------------------------

tar -xf Qt.tar.gz

#--------------------------------------------------------------------------------------------------
# Configure
#--------------------------------------------------------------------------------------------------

echo "CONFIGURE Qt"

cd $Qt

./configure -release \
            -opensource \
            -confirm-license \
            -nomake examples \
            -skip qtdoc \
            -verbose \

#--------------------------------------------------------------------------------------------------
# Build
#--------------------------------------------------------------------------------------------------

echo "BUILD Qt"

make | tail -n 1000

make install INSTALL_ROOT=$PWD/../deploy
