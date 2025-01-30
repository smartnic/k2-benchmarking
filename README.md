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

### Future steps

#### 1
_GOAL_: Utilize non-generic versions of the .desc files, which include two parameters: pgm_input_type and max_pkt_sz. Currently, there is a single file located in the "extra" directory that is used for all eBPF programs, but this may lead to erroneous behavior, as there are different types of eBPF programs, and programs can interact differently with different packet sizes.

- It may be possible to auto-generate one or both of these values, but this may prove to be too much of an effort, and can be left instead to people using this benchmarking utility.
- pgm_input_type is an integer in the .desc file, but a proper mapping can likely be obtained through exploration of how K2 internally maps this value to a more verbose description.
- similarly, it may be the case that a very large value of max_pkt_sz can work for all eBPF programs (or perhaps the opposite). Further examination of this value is recommended.

#### 2
_GOAL_: Allow for K2 to work on additional types of eBPF programs.

- From testing, several errors occurred when K2 ran on some programs, which likely stems from the fact that K2 does not cover all eBPF program types.
- This is a much more open-ended and extensive goal, but it is still important to mention.

#### 3
_GOAL_: Create a folder that users can place already-compiled object files in to run K2 on.

- Currently, this has not been implemented because the compiler version associated with an object file would not be explicitly obtainable.
- However, it could still be very useful for benchmarking, nonetheless, and would be relatively trivial to implement.

#### 4
_GOAL_: Create a tool that would place post-K2-optimized bytecode back into an object file.

- This has been attempted for very simple cases (i.e., no maps and relos) through the ebpf-reassembler repository.
- But for more complex cases, option 2 as described in 'notes.txt' in ebpf-reassembler is likely the best choice to pursue.
- Likely the most fruitful endeavor in the list of future steps, as it can have a very wide use case.
- But conversely, it requires extensive knowledge/research/testing of ELF files, and it may suffer if the eBPF object file specification changes over time.

#### 5
_GOAL_: Add additional eBPF compilers to the benchmarking utility

- Currently, this tool compares different versions of clang, but it would also be extremely useful to make comparisons of say, the best version of clang and the best version of gcc.

#### 6
_GOAL_: Add additional metric testing methods

- Currently, the only metric is the # of instructions reduced (a) after clang compilation and (b) after K2 compilation. This metric was quite easy to implement because the hardware does not necessarily bias results, unlike a metric such as the time taken to compile.
- However, other metrics, such as throughput testing, can also be included in the 2 aforementioned steps.
- These metrics would most likely require more sophisticated testing environments, such as CloudLab.

#### 7
_GOAL_: Add ease-of-access for changing Linux versions

- The current version of Linux in this repository is hardcoded to 6.9, which can become outdated in the future and lead to incompatibilities with older clang versions (e.g. 9.0.0, which is the case right now).
- This should be easy to implement, but as shown with the files in extra/linux, several files may have to be overridden to ensure everything, such as the Makefile in samples/bpf running, works correctly.

#### 8
_GOAL_: Modify K2 itself for better compilation.

- Similar to goal (2), this is an open-ended and extensive undertaking, as MANY optimizations can be pursued to achieve faster compilation times and better program compression.
- An example I personally found very interesting is one mentioned by Prof. Narayana, describing a process to run a system of equations on many eBPF programs to obtain eBPF instruction costs that are unique to a user's hardware. For example, if {a, b, c} are eBPF instructions, one example program would be 3a + 5b + 9c = {program runtime}, and several of these would be provided to solve for {a, b, c}. This would provide more accurate heuristics for the "true cost" of an eBPF program during the local search process in K2.
- Besides more accurate program costs, other places to target could include the search algorithm itself.
