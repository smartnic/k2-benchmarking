#!/bin/bash

if [ -d k2-window-generator ]; then
    echo "k2-window-generator: directory already exists"
    exit 1
fi

git clone https://github.com/smartnic/k2-window-generator.git
cd k2-window-generator
gcc window_generator.c -o window_generator
cd ..
