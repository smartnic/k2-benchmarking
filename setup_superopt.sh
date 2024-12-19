#!/bin/bash

if [ -d superopt ]; then
    echo "superopt: directory already exists"
    exit 1
fi

git clone https://github.com/smartnic/superopt.git
cd superopt
git checkout sigcomm2021_artifact
make -j $(nproc) k2_inst_translater.out
make -j $(nproc) main_ebpf.out
make -j $(nproc) z3server.out
cd ..
