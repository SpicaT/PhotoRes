#!/bin/bash

make clean
sudo xcode-select -s /Applications/Xcode-9.4.1.app
make DEBUG=0 ARCHS="armv7 arm64"
sudo xcode-select -s /Applications/Xcode.app
make DEBUG=0 ARCHS="armv7 arm64 arm64e"
make DEBUG=0 package FINALPACKAGE=1 $1 $2