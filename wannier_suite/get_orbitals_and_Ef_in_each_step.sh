#!/bin/bash
home_dir=$(pwd)
signature=$0
#script_dir=
#tmp_dir=
#mkdir 

#read -p "enter the prefix: " prefix
#read -p "enter the ref pwin file: " f_ref

#--------------------------------------------------------

ispin_value=$(grep -oP 'ISPIN\s*=\s*\K\d+' ../INCAR)

if [ "$ispin_value" -eq 1 ]; then
  /public1/home/sch0149/script/wannier_suite/get_orbitals_and_Ef_in_each_step.ispin1.py ../OUTCAR
else
  /public1/home/sch0149/script/wannier_suite/get_orbitals_and_Ef_in_each_step.ispin2.py ../OUTCAR
fi
