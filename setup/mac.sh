#!/bin/bash

cd vendor/Minecraft-Overviewer

# start with a clean place to work
python ./setup.py clean

# get PIL
if [ ! -d "`pwd`/Imaging-1.1.7/libImaging" ]; then
    /usr/bin/curl -o imaging.tgz http://effbot.org/media/downloads/Imaging-1.1.7.tar.gz
    tar xzf imaging.tgz
    rm imaging.tgz
fi

# build MCO
PIL_INCLUDE_DIR="`pwd`/Imaging-1.1.7/libImaging" python ./setup.py build
