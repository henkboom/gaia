#!/bin/sh
TARGET_DIR=gaia_windows PLATFORM=MINGW CC=i586-mingw32msvc-gcc CXX=i586-mingw32msvc-g++ make && mv gaia_windows/gaia gaia_windows/gaia.exe
