#!/bin/bash

build_instance(){
        local version=$1
        local folder="files-$version"

        if [ -d $folder ]; then
                return
        fi

        mkdir $folder && cd $folder
        make -C "/usr/src/app/linux/samples/bpf" clean
        make -C "/usr/src/app/linux/samples/bpf" \
             LLC="/usr/src/app/llvmorg-$version/build/bin/llc" \
             CLANG="/usr/src/app/llvmorg-$version/build/bin/clang" \
             OPT="/usr/src/app/llvmorg-$version/build/bin/opt" \
             LLVM_DIS="/usr/src/app/llvmorg-$version/build/bin/llvm-dis" \
             LLVM_OBJCOPY="/usr/src/app/llvmorg-$version/build/bin/llvm-objcopy" \
             LLVM_READELF="/usr/src/app/llvmorg-$version/build/bin/llvm-readelf"

        local files=(
                "syscall_tp_kern.o" "sockex3_kern.o" "xdp_router_ipv4.bpf.o" "xdp_fwd_kern.o"
        )

        for file in "${files[@]}"; do
                ../bpf-elf-tools/text-extractor/elf_extract "/usr/src/app/linux/samples/bpf/$file"
        done

        cd ..
}

build_instance "18.1.6"
build_instance "15.0.0"
build_instance "12.0.0"
build_instance "9.0.0"
