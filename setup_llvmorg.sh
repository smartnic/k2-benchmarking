#!/bin/bash

build_llvm(){
	local version=$1
	local folder="llvmorg-$version"

	if [ -d $folder ]; then
    	echo "$folder: directory already exists"
		return
	fi

	wget -O llvmorg.tar.xz "https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-$version.tar.gz"
	mkdir $folder && tar -xf llvmorg.tar.xz -C $folder --strip-components 1 && rm llvmorg.tar.xz
	cd $folder

	if [ $version == "12.0.0" ]; then
		cp ../extra/llvmorg-12.0.0/Signals.h llvm/include/llvm/Support/Signals.h
	fi

	mkdir build && cd build
	cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm
	make -j$(nproc)
	cd ../..
}

# For versions <= 9.0.0 (these do not use a monorepo structure)
build_llvm_legacy(){
	local version=$1
	local folder="llvmorg-$version"

	if [ -d $folder ]; then
    	echo "$folder: directory already exists"
		return
	fi

	mkdir $folder && cd $folder

	local components=(
		"cfe" "clang-tools-extra" "compiler-rt" "libcxx" "libcxxabi" "libunwind"
		"lld" "lldb" "llvm" "openmp" "polly" "test-suite"
	)

	for component in "${components[@]}"; do
		wget "https://releases.llvm.org/$version/$component-$version.src.tar.xz"
	done

	ls *.tar.xz | xargs -n1 tar -xJf
	rm *.tar.xz
	rename "s/-$version\.src$//" *
	mv cfe clang

	cp ../extra/llvmorg-9.0.0/benchmark_register.h llvm/utils/benchmark/src/benchmark_register.h
	cp ../extra/llvmorg-9.0.0/MicrosoftDemangle.h llvm/include/llvm/Demangle/MicrosoftDemangle.h
	cp ../extra/llvmorg-9.0.0/MicrosoftDemangleNodes.h llvm/include/llvm/Demangle/MicrosoftDemangleNodes.h

	mkdir build && cd build
	cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm
	make -j$(nproc)
	cd ../..
}

mapfile -t versions < "llvmorg_versions.txt"

for version in "${versions[@]}"; do
	echo "Attempting to build llvmorg-$version..."
	build_llvm $version
done