#!/bin/bash

if [ -d superopt ]; then
        exit 1
fi

git clone https://github.com/smartnic/superopt.git
cd superopt
make -j$(nproc) main_ebpf.out
cd ..
