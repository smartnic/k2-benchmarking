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

                k2_cmd="../superopt/main_ebpf.out --bm_from_file --desc ${bm_file}.desc --bytecode ${bm_file}.insns --map ${bm_file}.maps -k 1 --is_win --port 8000 --logger_level 1 --w_e 0.>
                $k2_cmd > "${output_dir}-log.txt"
        done
done
