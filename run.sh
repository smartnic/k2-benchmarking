#!/bin/bash

if [ -d "results" ]; then
	echo "results: directory already exists"
	exit 1
fi

num_iters=125000 # How many iterations K2 should run for

mapfile -t files < "target_program_files.txt"
mapfile -t versions < "llvmorg_versions.txt"

mkdir results && cd results

for file in "${files[@]}"; do
	for version in "${versions[@]}"; do
		bm_file="../files-$version/$file"
		bm_file_desc="../extra/k2/sample"
		output_dir="../results/$file-$version/"
		echo "Running \"$bm_file\" and saving to \"$output_dir\"..."

		if [ ! -f "${bm_file_desc}.desc" ] || [ ! -f "${bm_file}.insns" ] || [ ! -f "${bm_file}.maps" ]; then
			echo "one or more files not found"
			continue
		fi

		window_args=$(../k2-window-generator/window_generator ${bm_file}.txt)

		if [ $? -ne 0 ]; then
			echo "no windows found for ${bm_file}.txt, skipping..."
			continue
		fi

		mkdir $output_dir
		k2_cmd="./main_ebpf.out --bm_from_file --desc ${bm_file_desc}.desc --bytecode ${bm_file}.insns --map ${bm_file}.maps -k 1 --is_win --port 8000 --logger_level 1 --w_e 0.5 --w_p 5 --st_ex 0 --st_eq 0 --st_avg 0 --st_perf 0 --st_when_to_restart 0 --st_when_to_restart_niter 0 --st_start_prog 0 --p_inst_operand 0.33333333 --p_inst 0.33333333 --p_inst_as_nop 0.15 --reset_win_niter 50000 ${window_args} --path_res ${output_dir} -n $num_iters"
		(cd ../superopt && $k2_cmd > "${output_dir}log.txt")
	done
done

echo "Writing results to table..."
cd ..
python3 table.py > results/table.txt