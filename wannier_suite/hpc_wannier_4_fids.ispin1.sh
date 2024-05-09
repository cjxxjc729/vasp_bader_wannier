#!/bin/bash


if [ -z "$1" ]
then
  echo "usage: hpc_wannier_4_fids.sh <list_name_that_contains_fids_to_do>"
  exit 1
fi

fids_list_name=$1
fids_to_do_list_name="${fids_list_name}.todo.t"
fids_to_check=$(cat $fids_list_name | xargs)


if [ -f ${fids_to_do_list_name} ]
then
  rm ${fids_to_do_list_name}
fi

echo " "
echo "$1"
echo "to do list:"
for fid in $fids_to_check
do
  if [ ! -f ${fid}/wannier90.wout ] && [ -d ${fid} ]
  then
    echo "${fid}"
    echo "$fid" >> ${fids_to_do_list_name}
   
  fi

done

echo ""

if [ ! -f ${fids_to_do_list_name} ]
then
  echo "no fids selected"
  exit 1
fi



nfids_to_do=$(cat ${fids_to_do_list_name} | wc -l)
Ncore_use=$( echo "${nfids_to_do}" | bc -l | awk {printf'("%d\n",$0)'})


echo "#!/bin/bash
#SBATCH -p v6_384
#SBATCH -N 1
#SBATCH -n $Ncore_use
export PATH=/public1/home/sch0149/deepmd/miniconda3/bin:\$PATH
export OMP_NUM_THREADS=1 

fids_to_do_wannier=\$(cat ${fids_to_do_list_name} | xargs )      #aleady exclude the files that will not do

/public1/home/sch0149/script/wannier_suite/wannier_4_fids.ispin1.sh << EOF
\${fids_to_do_wannier}
EOF

" > ${fids_list_name}_hpcN${Ncore_use}.sh



chmod +x ${fids_list_name}_hpcN${Ncore_use}.sh


sbatch ${fids_list_name}_hpcN${Ncore_use}.sh


