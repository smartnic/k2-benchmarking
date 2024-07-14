FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
	wget               \
	xz-utils           \
	make               \
	gcc                \
	flex               \
	bison              \
	libelf-dev         \
	bc                 \
	libssl-dev         \
	rsync              \
	python3            \
	cmake              \
	g++                \
	rename             \
	git                \
	python3-setuptools \
	pahole             \
	iputils-ping       \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY overrides overrides
COPY setup.sh setup.sh
COPY build.sh build.sh
COPY run.sh run.sh
COPY setup_bpf-elf-tools.sh setup_bpf-elf-tools.sh
COPY setup_linux.sh setup_linux.sh
COPY setup_llvmorg.sh setup_llvmorg.sh
COPY setup_superopt.sh setup_superopt.sh
COPY setup_z3.sh setup_z3.sh

CMD ["/bin/bash"]
