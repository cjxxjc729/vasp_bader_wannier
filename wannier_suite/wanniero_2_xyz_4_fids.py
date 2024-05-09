#!/public1/home/sch0149/deepmd-kit/bin/python

import numpy as np
import re
import sys
from ase.io import read,write
from ase import Atoms
import os

def extract_and_reshape_with_numpy(file_path, start_keyword, end_keyword):
    with open(file_path, 'r') as file:
        content = file.read()

    pattern = re.compile(rf"{re.escape(start_keyword)}(.*?){re.escape(end_keyword)}", re.DOTALL)
    matches = pattern.findall(content)

    all_data = []
    for match in matches:
        bracket_contents = re.findall(r'\((.*?)\)', match)
        step_data = [float(num) for s in bracket_contents for num in s.split(',')]
        all_data.extend(step_data)

    # 将数据转换为Numpy数组并重塑为(100, 976, 3)
    reshaped_array = np.array(all_data).reshape(-1, len(bracket_contents), 3)
    return reshaped_array


def wanniero_to_xyz(file_path):
  
  # 应用函数到文件
  start_keyword = "Cycle:"
  end_keyword = "Sum of centres and spreads"
  numpy_reshaped_content = extract_and_reshape_with_numpy(file_path, start_keyword, end_keyword)

  prefix=file_path.split('.wout')[0]
  fid_name_tmp=file_path.split('/')[:-1]
  fid_name='/'.join(fid_name_tmp)

  cors=numpy_reshaped_content[-1]

  if os.path.isfile(fid_name+'/e_fermi.txt'):

    print("find e_fermi.txt, only look at the oribtials below Fermi")
    Ef = np.loadtxt(fid_name+'/e_fermi.txt')  

    if prefix == fid_name+'/wannier90':
    
      print("无spin工作")
      orb_infor = np.loadtxt(fid_name+'/spin_component.txt') 

    elif prefix == fid_name+'/wannier90.up':

      print("spin up 工作")
      orb_infor = np.loadtxt(fid_name+'/spin_component_1.txt') 

    elif prefix == fid_name+'/wannier90.dn':
 
      print("spin down 工作")
      orb_infor = np.loadtxt(fid_name+'/spin_component_2.txt')

    nele=len(np.where(orb_infor[:,1]< Ef)[0])
    print("共有", nele, "个电子")
    atoms=Atoms('Ne'+str(nele),positions=cors[:nele]) 

  else:
  
    atoms=Atoms('Ne'+str(len(cors)),positions=cors)


  if os.path.isfile(fid_name+'/snap.cif'):

    print("read cell from snap.cif")
    atoms_snap=read(fid_name+'/snap.cif')

    cell=atoms_snap.get_cell()
    atoms.set_cell(cell)
    atoms.wrap(pbc=[1,1,1])

    new_atoms=atoms_snap+atoms

    if os.path.isfile(fid_name+'/e_fermi.txt'):
      #write Qs
      Qs=np.zeros(len(new_atoms))
      Qs[len(atoms_snap):len(new_atoms)] = orb_infor[:nele,2]
      new_atoms.set_initial_charges(Qs)

    write(prefix+'.xyz',new_atoms)

  else:
    new_atoms = atoms
    write(prefix+'.xyz',new_atoms)

  return new_atoms
  


import os

# 递归地搜索当前目录及所有子目录下匹配 "wannier*.wout" 的文件
fs_wannier = [os.path.join(dp, f) for dp, dn, filenames in os.walk('.') for f in filenames if f.startswith("wannier") and f.endswith(".wout")]
fs_wannier.sort()

atoms_step=[]

for f_wannier in fs_wannier:
  print("------",f_wannier,"---------") 
  new_atoms=wanniero_to_xyz(f_wannier) 

  atoms_step.append(new_atoms)


write('wannier_by_step.xyz',atoms_step)
