#!/public1/home/sch0149/deepmd-kit/bin/python

import os
import sys

def extract_data_without_regex(content, start_keyword, end_keyword):
    lines = content.split('\n')
    extracted_data = []
    capture = False

    for line in lines:
        if start_keyword in line:
            capture = True  # 开始捕获数据
        elif end_keyword in line and capture:
            break  # 结束捕获数据
        elif capture:
            extracted_data.append(line)  # 捕获数据行

    return '\n'.join(extracted_data)

def save_data_to_folders_v2(content, base_directory="./"):
    lines = content.split('\n')
    folder_number = 1
    e_fermi_value = ""

    for i, line in enumerate(lines):
        if 'E-fermi :' in line:
            # 提取 E-fermi 值
            e_fermi_value = line.split(':')[1].split()[0]
        elif 'spin component 1' in line:
            # 提取并保存 "spin component 1" 的数据
            folder_path = os.path.join(base_directory, str(folder_number).zfill(5))
            os.makedirs(folder_path, exist_ok=True)
            spin_component_1_data = extract_data_without_regex('\n'.join(lines[i:]), 'band No.  band energies     occupation', 'spin component 2')
            with open(os.path.join(folder_path, 'spin_component_1.txt'), 'w') as file:
                file.write(spin_component_1_data)
            with open(os.path.join(folder_path, 'e_fermi.txt'), 'w') as file:
                file.write(e_fermi_value)
        elif 'spin component 2' in line:
            # 提取并保存 "spin component 2" 的数据
            folder_path = os.path.join(base_directory, str(folder_number).zfill(5))
            spin_component_2_data = extract_data_without_regex('\n'.join(lines[i:]), 'band No.  band energies     occupation', '-----------')
            with open(os.path.join(folder_path, 'spin_component_2.txt'), 'w') as file:
                file.write(spin_component_2_data)
            folder_number += 1

# 使用示例
file_path = sys.argv[1]
try:
    with open(file_path, 'r') as file:
        outcar_content = file.read()
except Exception as e:
    outcar_content = str(e)

# 调用函数保存数据到文件夹
save_data_to_folders_v2(outcar_content)

# 打印完成消息
print("Data extraction and saving complete.")

