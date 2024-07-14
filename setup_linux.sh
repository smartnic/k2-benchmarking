#!/bin/bash

if [ -d linux ]; then
	exit 1
fi

wget -O linux.tar.xz "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.9.tar.xz"
mkdir linux && tar -xf linux.tar.xz -C linux --strip-components 1 && rm linux.tar.xz
cp overrides/linux/.config linux/.config
cd linux
make -j$(nproc)
make -j$(nproc) headers_install
cp ../overrides/linux/syscall_nrs.c samples/bpf/syscall_nrs.c
