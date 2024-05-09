#!/bin/bash


if [ -z "$1" ]
then
  echo "usage: hpc_wannier_4_mmn_in_subdirs.sh <list_name_that_contains_fs_mmn_to_do>"
  exit 1
fi

fmmn_list_name=$1

ncore=$(cat $fmmn_list_name | wc -l)

sed "s/mmn_list_file_name/$fmmn_list_name/g" /public1/home/sch0149/script/wannier_suite/hpc_wannier_4_submmn.example.in > ${fmmn_list_name}_hpcN${ncore}.sh

sed -i "s/ncore/$ncore/g"  ${fmmn_list_name}_hpcN${ncore}.sh


chmod +x ${fmmn_list_name}_hpcN${ncore}.sh


sbatch ${fmmn_list_name}_hpcN${ncore}.sh


