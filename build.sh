#!/bin/bash

mapfile -t files < "target_object_files.txt"

build_instance(){
	local version=$1
	local folder="files-$version"

	if [ -d $folder ]; then
		echo "$folder: directory already exists"
		return
	fi

	mkdir $folder && cd $folder

	# If debugging, remove the "> /dev/null 2>&1" portion to show output.
	echo "Running bpf makefile with clang-$version..."
	make -C "../linux/samples/bpf" clean > /dev/null 2>&1
	make -C "../linux/samples/bpf" \
	     LLC="../llvmorg-$version/build/bin/llc" \
	     CLANG="../llvmorg-$version/build/bin/clang" \
	     OPT="../llvmorg-$version/build/bin/opt" \
	     LLVM_DIS="../llvmorg-$version/build/bin/llvm-dis" \
	     LLVM_OBJCOPY="../llvmorg-$version/build/bin/llvm-objcopy" \
	     LLVM_READELF="../llvmorg-$version/build/bin/llvm-readelf" > /dev/null 2>&1

	for file in "${files[@]}"; do
		echo "Extracting $file ($version)..."
		(cd ../ebpf-extractor && ./ebpf_extractor "../linux/samples/bpf/$file")
		cp ../linux/samples/bpf/$file .
		mv ../ebpf-extractor/*.insns ../ebpf-extractor/*.maps ../ebpf-extractor/*.rel ../ebpf-extractor/*.txt . 2>/dev/null
	done

	cd ..
}

mapfile -t versions < "llvmorg_versions.txt"

for version in "${versions[@]}"; do
	echo "Attempting to compile files with llvmorg-$version..."
	build_instance $version
done
