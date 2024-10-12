#!/bin/bash

build_instance(){
        local version=$1
        local folder="files-$version"

        if [ -d $folder ]; then
                return
        fi

        mkdir $folder && cd $folder
        make -C "../linux/samples/bpf" clean
        make -C "../linux/samples/bpf" \
             LLC="../llvmorg-$version/build/bin/llc" \
             CLANG="../llvmorg-$version/build/bin/clang" \
             OPT="../llvmorg-$version/build/bin/opt" \
             LLVM_DIS="../llvmorg-$version/build/bin/llvm-dis" \
             LLVM_OBJCOPY="../llvmorg-$version/build/bin/llvm-objcopy" \
             LLVM_READELF="../llvmorg-$version/build/bin/llvm-readelf"

        local files=(
                "syscall_tp_kern.o" "sockex3_kern.o" "xdp_router_ipv4.bpf.o" "xdp_fwd_kern.o"
        )

        for file in "${files[@]}"; do
		echo "--- RESOLVING $file-$version ---"
                (cd ../ebpf-extractor && ./ebpf_extractor "../linux/samples/bpf/$file")
		mv ../ebpf-extractor/*.insns ../ebpf-extractor/*.maps ../ebpf-extractor/*.rel ../ebpf-extractor/*.txt . 2>/dev/null
        done

        cd ..
}

build_instance "18.1.6"
#build_instance "15.0.0"
#build_instance "12.0.0"
#build_instance "9.0.0"
