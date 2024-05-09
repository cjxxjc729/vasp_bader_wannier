#!/bin/bash


if [ ! -f ../wannier90.win ]
then
  echo "wrong ! should be placed in bader.tmp and run vasp by with_wannier"
  exit 1
fi


source /public1/soft/modules/module.sh
module load mpi/intel/2022.1

home_dir=$(pwd)

read -p "enter the fids name to do wannier90.x : " fids

#--------------------------------------------------------------------------#
echo "parepring the wannier90.win file"

if [ ! -f wannier90.win ]
then
  sed "/mp_grid/a gamma_only = true" ../wannier90.win > wannier90.win
fi


for fid in $fids
do
  echo "----------$fid -------------"
  cp wannier90.win $fid
  cd $fid

    cp wannier90.win wannier90.up.win  
  
    echo "wannier90.x wannier90.up.win &"      
    /public1/home/sch0149/tools/wannier90-2.1.0/wannier90.x wannier90.up.win & 

    cp wannier90.win wannier90.dn.win

    echo "wannier90.x wannier90.dn.win &"
    /public1/home/sch0149/tools/wannier90-2.1.0/wannier90.x wannier90.dn.win &

    #sleep 5s

  cd $home_dir
done

echo "sleep 30s, there enter the progree checing process"
sleep 30s

echo "progress checking"
echo "waitng for them to be done"

for fid in $fids
do

  count=0
  while ! grep -q "All done: wannier90 exiting" $fid/wannier90.up.wout || ! grep -q "All done: wannier90 exiting" $fid/wannier90.dn.wout
  do
    ((count=count+1))
    sleep 10s
    if [ $((count % 30)) -eq 0 ]; then
      echo "${count}0 s has passed"
      echo "dont worry, it is still running"
    fi
  done

  #while ! grep -q "All done: wannier90 exiting" $fid/wannier90.dn.wout
  #do
  #  sleep 10s
  #done

  echo "$fid is done"
  rm $fid/wannier90.up.mmn $fid/wannier90.dn.mmn
done
