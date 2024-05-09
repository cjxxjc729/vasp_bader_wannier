#!/bin/bash
home_dir=$(pwd)
signature=$0
#script_dir=
#tmp_dir=
#mkdir 

#read -p "enter the prefix: " prefix
read -p "enter the bader insitu fid(s): " bader_insitu_fids

#--------------------------------------------------------


for bader_insitu_fid in $bader_insitu_fids
do
  echo "----------- $bader_insitu_fid ----------"
  cd $bader_insitu_fid

    bader_4_vasp_del_fchg.sh

  cd $home_dir
done
