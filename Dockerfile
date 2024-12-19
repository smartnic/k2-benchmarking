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
	python3-pip        \
	cmake              \
	g++                \
	rename             \
	git                \
	python3-setuptools \
	pahole             \
	iputils-ping       \
	&& rm -rf /var/lib/apt/lists/*

RUN pip3 install prettytable

WORKDIR /usr/src/app

COPY llvmorg_versions.txt llvmorgs_versions.txt
COPY target_object_files.txt target_object_files.txt
COPY target_program_files.txt target_program_files.txt
COPY extra extra
COPY setup.sh setup.sh
COPY build.sh build.sh
COPY run.sh run.sh
COPY table.py table.py
COPY setup_ebpf-extractor.sh setup_ebpf-extractor.sh
COPY setup_k2-window-generator.sh setup_k2-window-generator.sh
COPY setup_linux.sh setup_linux.sh
COPY setup_llvmorg.sh setup_llvmorg.sh
COPY setup_superopt.sh setup_superopt.sh
COPY setup_z3.sh setup_z3.sh

CMD ["/bin/bash"]
