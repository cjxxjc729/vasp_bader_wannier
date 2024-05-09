#!/bin/bash
home_dir=$(pwd)
signature=$0
#script_dir=
#tmp_dir=
#mkdir 

echo "收集mmn文件"
# 执行Python代码
python -c "
import os
import fnmatch

def find_files(directory, pattern):
    for root, dirs, files in os.walk(directory):
        for basename in files:
            if fnmatch.fnmatch(basename, pattern):
                filename = os.path.join(root, basename)
                yield filename

def check_wout_file(wout_file):
    with open(wout_file, 'r') as file:
        for line in file:
            if 'All done: wannier90 exiting' in line:
                return True
    return False

def main():
    search_dir = '.'  # 设置搜索的起始目录
    mmn_files = list(find_files(search_dir, 'wannier90*.mmn'))
    todo_files = []

    for mmn_file in mmn_files:
        wout_file = mmn_file.replace('.mmn', '.wout')
        if os.path.exists(wout_file) and check_wout_file(wout_file):
            continue
        else:
            todo_files.append(mmn_file)

    with open('wannier_todo_list.txt', 'w') as f:
        for file in todo_files:
            f.write('%s\n' % file)

if __name__ == '__main__':
    main()
"

#awk -F'/' '{NF--; OFS="/"; $1=$1; print}' wannier_todo_list.txt | sort -u > f.wmmn.t; mv f.wmmn.t wannier_todo_list.txt ;rm f.wmmn.t

#-------------------step 2-----------------------------------#

echo "将他们分组"
seperate_files_inito_several_groups.by_max_iterm.sh << EOF
wannier_todo_list.txt
16
EOF

#----------------------step 3-------------------------------#

n_fs_group=$(ls -1 | grep "^wannier_todo_list.txt.sub_group_" |  wc -l)
echo "共 ${n_fs_group=} 组, 提交${n_fs_group=} 个任务, 16 core"
fs_group=$(ls -1 | grep "^wannier_todo_list.txt.sub_group_" | xargs)




for f_group in $fs_group
do
  echo "-------------------for:$f_group--------------------"
  job_num_control
  /public1/home/sch0149/script/wannier_suite/hpc_wannier_4_mmn_in_subdirs.sh $f_group

done





