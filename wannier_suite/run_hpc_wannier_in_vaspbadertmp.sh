#!/bin/bash
home_dir=$(pwd)
signature=$0
#script_dir=
#tmp_dir=
#mkdir 

#read -p "enter the prefix: " prefix
#read -p "enter the ref pwin file: " f_ref
if [ ! -f ../wannier90.win ]
then
  echo "no wannier90.win, quit"
  exit 1
fi

# 检查ISPIN的值
ispin_value=$(grep -oP 'ISPIN\s*=\s*\K\d+' ../INCAR)


#--------------------------------------------------------

#
lld | grep ^[0-9] > wannier_fids.t

#计算spin_component_1.txt spin_component_2.txt 
/public1/home/sch0149/script/wannier_suite/get_orbitals_and_Ef_in_each_step.sh


if [ "$ispin_value" -eq 1 ]; then
  #/public1/home/sch0149/script/wannier_suite/get_orbitals_and_Ef_in_each_step.ispin1.py ../OUTCAR 
  seperate_files_inito_several_groups.by_max_iterm.sh << EOF
wannier_fids.t
16
EOF
else
  #/public1/home/sch0149/script/wannier_suite/get_orbitals_and_Ef_in_each_step.ispin2.py ../OUTCAR
  seperate_files_inito_several_groups.by_max_iterm.sh << EOF
wannier_fids.t
8
EOF
fi

to_do_list=$(ls -1 | grep sub_group_ | xargs)

for f_list in $to_do_list
do
  if [ "$ispin_value" -eq 1 ]; then
    hpc_wannier_4_fids.ispin1.sh $f_list 
  else
    hpc_wannier_4_fids.sh $f_list
  fi
done

sleep 30s


# 检查当前目录中是否有以to_do.t结尾的文件
if ls *.todo.t 1> /dev/null 2>&1; then
    echo "找到以to_do.t结尾的文件。"
else
    echo "没有找到以to_do.t结尾的文件，退出脚本。"
    exit 1
fi



holdon_v1

mkdir wannier.tmp

mv wannier* wannier.tmp
mv slurm-*.out wannier.tmp
mv wannier.tmp/wannier_by_step.xyz ./
