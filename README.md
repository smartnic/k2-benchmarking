## k2-benchmarking

This repository contains a series of tools that aim to test the K2 stochastic eBPF compiler with different versions of clang-bpf on Linux bpf samples.

### Motivation

It has been a few years since the [K2 compiler](https://k2.cs.rutgers.edu/) was released. To put it in perspective, the original paper utilized clang-9, whereas clang now has versions as new as clang-18. Thus, the main motivation was to see **(a)** how newer versions of clang operate on eBPF .c files and **(b)** how K2 itself operates on these clang-compiled object files.

To make this testing easy, the toolchain implemented in this repository allows the user to specify the version(s) of clang to test, combined with the specific eBPF programs they are interested in seeing the results of.

### Description of directories/files

- **extra:** this is a directory that contains several files that are automatically utilized throughout the toolchain. They mainly include corrections that avoid compilation errors I encountered during my testing. Each folder includes a README with descriptions of changes/usage.
- **testing:** this is a directory that contains sample output from running the toolchain in (2) different scenarios. The main files of importance are results_1.txt and results_2.txt.
- **Dockerfile:** this is the file used to run the optional Docker container.
- **build.sh:** this is the script that encompasses the building process that actually creates the eBPF object files for each version of clang. It also uses these object files to create the necessary K2 input files using the ebpf-extractor tool.
- **llvmorg_versions.txt:** this file is *user-modifiable*, specifying the version(s) of clang the user would like built. Note that versions of clang-9 and older will most likely not work with the version of the kernel, and also that only versions {12.0.0, 15.0.0, and 18.1.6} have been tested. Other versions newer than clang-9 should work, but may require similar corrections that I have outlined in the "extra" directory.
- **run.sh:** this script runs K2, and should be used after setup.sh and build.sh respectively.
- **setup.sh:** this is the script that sets up all necessary prerequisite libraries and should be run first.
- **setup_ebpf-extractor.sh:** a more granular script that is already called by *setup.sh*, but can be called individually by the user as well for setting up the ebpf-extractor repo.
- **setup_k2-window-generator.sh:** a more granular script that is already called by *setup.sh*, but can be called individually by the user as well for setting up the k2 window generator repo.
- **setup_linux.sh:** a more granular script that is already called by *setup.sh*, but can be called individually by the user as well for setting up linux.
- **setup_llvmorg.sh:** a more granular script that is already called by *setup.sh*, but can be called individually by the user as well for setting up llvm/clang.
- **setup_superopt.sh:** a more granular script that is already called by *setup.sh*, but can be called individually by the user as well for setting up K2.
- **setup_z3.sh:** a more granular script that is already called by *setup.sh*, but can be called individually by the user as well for setting up z3, a required prerequisite for K2.
- **table.py:** this is the script that is called by **run.sh** to compile the entire results directory into a human-readable table that makes it easy to see how K2 performed between different files/versions. N/A in the table dictates that there was an error of some sort. Sometimes, there may be a number of instructions after running K2 rather than N/A, but an error still internally occurred leading to K2 early-exiting. In this case, consulting the logs in *results* is useful for debugging.
- **target_object_files.txt:** the object files from the Linux source code that the user is interested in.
- **target_program_files.txt:** the programs (which are a subset of all programs output by the object files in target_object_files.txt) that the user is interested in.

### Usage
#### Using the container

Before running/configuring the toolchain, there is an option to launch a Docker container:

1) docker build -t <image-name> .
2) docker run -it --privileged <image-name>

#### Running the toolchain

Before running the toolchain, the user can configure the values of the following files; otherwise, there is a default configuration that can already be used:
1) **llvmorg_versions.txt**: the versions of clang the user is interested in using
2) **target_object_files.txt**: within linux/samples/bpf, the object file(s) the user is interested in pulling programs from
3) **target_program_files.txt**: with the aforementioned object files, the specific program(s) the user would like pulled from. An object file contains multiple programs, thus the user must specify here which ones they are interested in.

Then, they can run the toolchain in this order:
1) ./setup.sh -- sets up all of the prerequisite tools, including linux, llvm (for each version), K2, ebpf-extractor, k2-window-generator, etc.
2) ./build.sh -- compiles and accumulates these files
3) ./run.sh -- feeds the files into K2 and creates output table

Once everything is done running, several directories are created:
1) linux -- this is the linux build that is used to compile ebpf samples (located at linux/samples/bpf, where the local makefile is used)
2) llvmorg-{version} for each specified version -- this contains the binaries for each version of llvm (including clang and various other tools like readelf)
3) files-{version} for each specified version -- this contains the output files for each target program that will be fed into K2
4) results -- this is the directory that contains both **table.txt** showcasing the overall results, as well as logs for each individual {file}-{version} sample. In total, the upper bound of results in the table is (# of programs * # of versions), however if no valid window is found, or if there are errors running the linux makefile/ebpf-extractor, this number will decrease.

During runtime, there will also be lots of verbose output that can be used for debugging purposes.

### Difficulties

1) The current version of the Linux kernel used (6.9) is static and cannot be changed with ease.
2) Similarly, the version of the Linux kernel is new enough to make running bpf samples with clang-9 yield compilation errors.
3) Although lots of effort has been taken to remediate errors during compilation, there are still a decent number of ebpf programs that yield errors when running through K2. Some of these can be observed in testing/{out_1,out_2}.txt. It is difficult to determine why exactly these errors occur, thus more debugging is required.
4) As mentioned, the repository only contains Linux bpf samples to test. Other samples were difficult to integrate because they required their own "environment" with custom dependencies, etc.
5) The Docker container may yield some errors/lack of dependencies.

### Other related repositories

Each project below was also created as part of the independent study effort. Each repo contains a README that expands upon its purpose.

#### Used directly
1) https://github.com/smartnic/ebpf-extractor
2) https://github.com/smartnic/k2-window-generator

#### Not used directly, but relevant
1) https://github.com/smartnic/ebpf-instruction-resolver
2) https://github.com/smartnic/ebpf-inline-testing
3) https://github.com/smartnic/ebpf-reassembler
