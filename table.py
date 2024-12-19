import os
from prettytable import PrettyTable

def get_lines(filename):
    with open(filename, 'r') as f:
        return [line.strip() for line in f.readlines()]

def get_instruction_count(filename):
    try:
        with open(filename, 'r') as f:
            return sum(1 for _ in f)
    except FileNotFoundError:
        return None

def get_k2_instruction_count(results_dir):
    try:
        with open(os.path.join(results_dir, 'log.txt'), 'r') as f:
            lines = f.readlines()
            for line in lines:
                if 'top 1' in line:
                    return int(line.split(' ')[-1])
    except FileNotFoundError:
        return None

def main():
    versions = get_lines('llvmorg_versions.txt')
    programs = get_lines('target_program_files.txt')
    
    table = PrettyTable()
    table.title = 'Number of Instructions'
    
    columns = ['Program', 'Version', 'Before K2', 'After K2', 'Reduction', 'Reduction (%)']
    table.field_names = columns
    
    for program in programs:
        for version in versions:
            results_dir = f'results/{program}-{version}'
            
            if os.path.exists(results_dir):
                # Get number of instructions before K2
                clang_file = f'files-{version}/{program}.txt'
                clang_count = get_instruction_count(clang_file)
                
                # Get number of instructions after K2
                k2_count = get_k2_instruction_count(results_dir)
                
                if clang_count and k2_count:
                    reduction = clang_count - k2_count
                    reduction_str = str(reduction)
                    reduction_percent = 100 * float(reduction) / clang_count 
                    reduction_percent_str = f'{reduction_percent:.2f}%'
                else:
                    reduction_str = 'N/A'
                    reduction_percent_str = 'N/A'
                
                row = [
                    program,
                    version,
                    str(clang_count) if clang_count else 'N/A',
                    str(k2_count) if k2_count else 'N/A',
                    reduction_str,
                    reduction_percent_str
                ]
            else:
                row = [program, version, 'N/A', 'N/A', 'N/A', 'N/A']
            
            table.add_row(row)
            
    print(table)

if __name__ == '__main__':
    main()
