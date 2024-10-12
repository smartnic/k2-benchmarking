./setup_linux.sh
./setup_llvmorg.sh
./setup_ebpf-extractor.sh # This *MUST* be called after Linux is created, as it will attempt to obtain the version of libbpf used in Linux.
./setup_z3.sh
./setup_superopt.sh
