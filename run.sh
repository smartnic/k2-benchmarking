#!/bin/bash

if [ -d "results" ]; then
        exit 1
fi

mkdir results && cd results

files=(
        "tracepoint-syscalls-sys_enter_open" "socket-0" "socket-1" "xdp_fwd"
)

versions=(
        "18.1.6" "15.0.0" "12.0.0" "9.0.0"
)

for version in "${versions[@]}"; do
        for file in "${files[@]}"; do
                bm_file="../files-$version/$file"
                output_dir="$file-$version"
                echo "RUNNING \"$bm_file\" AND SAVING TO \"$output_dir\""

                if [ ! -f "${bm_file}.desc" ] || [ ! -f "${bm_file}.insns" ] || [ ! -f "${bm_file}.maps" ]; then
                        echo "  ONE OR MORE FILES NOT FOUND"
                        continue
                fi

		k2_cmd="../superopt/main_ebpf.out --bm_from_file --desc ${bm_file}.desc --bytecode ${bm_file}.insns --map ${bm_file}.maps -k 1 --is_win --port 8000 --logger_level 1 --w_e 0.5 --w_p 1.5 --st_ex 0 --st_eq 0 --st_avg 0 --st_perf 0 --st_when_to_restart 0 --st_when_to_restart_niter 0 --st_start_prog 0 --p_inst_operand 0.33333333 --p_inst 0.33333333 --p_inst_as_nop 0.15 --reset_win_niter 5000 --win_s_list 1 --win_e_list 9 --path_res $output_dir -n 25000"
                $k2_cmd > "${output_dir}-log.txt"
        done
done
