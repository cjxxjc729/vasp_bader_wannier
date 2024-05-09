#!/bin/bash
home_dir=$(pwd)
signature=$0
script_dir=/public1/home/sch0149/script/vasp_baderinsitu_suite/scripts

#read -p "enter the prefix: " prefix
#read -p "enter the ref pwin file: " f_ref

#--------------------------------------------------------

prefix=$(basename `pwd` | sed "s/\.cif\.vasp//g")

if [ ! -d bader.tmp ]
then
  echo "not a vasp insitu bader job, quit"
  exit 1
fi


if [ -d ./bader.tmp/snap_charge_list.xyz_coll ]
then
  rm -r ./bader.tmp/snap_charge_list.xyz_coll
fi

if [ -d ./bader.tmp/tmp_hpc_sub ]
then
  rm -r ./bader.tmp/tmp_hpc_sub
fi

if [ -d ./bader.tmp/uniorder_fids.hpc_multi.tmp ]
then
  rm -f ./bader.tmp/uniorder_fids.hpc_multi.tmp
fi

#---------------------做每一步的snap.cif-----------------------------

python -c "from ase.io import write,read

atoms_step=read('XDATCAR',index=':')

for step in range(len(atoms_step)):
  formed_step = str(step+1).zfill(5)
  fid=formed_step
  atoms=atoms_step[step]

  write('./bader.tmp/'+fid+'/snap.cif',atoms)"




#-----------------------hpc subgroup 套路----------------------------------#

cd bader.tmp/
  home_dir1=$(pwd)

  uniorder_fids.hpc_multi.sh << EOF
20
bader_4_vasp_del_fchg.sh
EOF

  echo "sleep 1m"
  sleep 1m
  echo "holdon_v1"
  holdon_v1

#------------------------------------------------------------
#
  #删除临时文件
  mkdir uniorder_fids.hpc_multi.tmp
  mv  fids.t.sub_group_* fids.t slurm-*out uniorder_fids.sub_group_*sh  uniorder_fids.hpc_multi.tmp
#cd bader.tmp
  digfs << EOF
snap_charge_list.xyz
EOF

  cd snap_charge_list.xyz_coll
    merge_all_xyzs_into_snaps.py

  cd $home_dir

ln -s bader.tmp/snap_charge_list.xyz_coll/all_steps.xyz ./${prefix}.insitu_bader.xyz


echo "-----------------LOCPOT------------------------------------------"

if [ -f bader.tmp/00010/LOCPOT.cube ]
then
  cd bader.tmp/
    ${script_dir}/get_avez_4_all.py  
  cd $home_dir
fi

echo "--------------------wannier -------------------------------------"
if [ -f wannier90.win ]
then
  cd bader.tmp
    echo "run wannier"
    hpc_sub_hide_trace run_hpc_wannier_in_vaspbadertmp.sh

    holdon_wait_following_dir_done_V2.sh ./tmp_hpc_sub

    #将文件夹中所有的wout文件转换成wannier.xyz文件
    echo "将文件夹中所有的wout文件转换成wannier.xyz文件"
    /public1/home/sch0149/script/wannier_suite/wanniero_2_xyz_4_fids.py >> /dev/null

  cd $home_dir

  ln -s bader.tmp/wannier_by_step.xyz ./${prefix}.wannier.xyz
else
  echo "no wannier"
fi
 
