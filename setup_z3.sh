#!/bin/bash

if [ -d z3 ]; then
	echo "z3: directory already exists"
	exit 1
fi

git clone https://github.com/Z3Prover/z3.git
cd z3
git checkout 1c7d27bdf31ca038f7beee28c41aa7dbba1407dd
python3 scripts/mk_make.py
cd build
make -j$(nproc)
make install
cd ../..
