#!/bin/bash

if [ -d ebpf-extractor ]; then
        exit 1
fi

git clone https://github.com/smartnic/ebpf-extractor.git
cd ebpf-extractor
libbpf_version_path="../linux/tools/lib/bpf/libbpf_version.h"
MAJOR_VERSION=$(grep LIBBPF_MAJOR_VERSION "$libbpf_version_path" | awk '{print $3}')
MINOR_VERSION=$(grep LIBBPF_MINOR_VERSION "$libbpf_version_path" | awk '{print $3}')
echo "Detected libbpf version: $MAJOR_VERSION.$MINOR_VERSION"
newest_compatible_version=$(git ls-remote --tags "https://github.com/libbpf/libbpf" | cut -d/ -f3 | grep "v$MAJOR_VERSION\\.$MINOR_VERSION" | tail -n1)
./libbpf_install.sh $newest_compatible_version
make
cd ..
