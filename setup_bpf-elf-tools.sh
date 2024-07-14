#!/bin/bash

if [ -d bpf-elf-tools ]; then
        exit 1
fi

git clone https://github.com/smartnic/bpf-elf-tools.git
cd bpf-elf-tools/text-extractor
make && gcc staticobjs/* -lelf -lz -o elf_extract
cd ../..
