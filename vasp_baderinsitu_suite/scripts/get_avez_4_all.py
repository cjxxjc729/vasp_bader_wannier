#!/public1/home/sch0149/deepmd-kit/bin/python


from ase.io import write
from ase.io import read
from ase.io.cube import read_cube_data
from ase.io.cube import read_cube
from ase import neighborlist
from ase import geometry
import numpy as np
import os
import time


locpot_files_exact = []
for root, dirs, files in os.walk('.'):
    for file in files:
        if file == 'LOCPOT.cube':
            locpot_files_exact.append(os.path.join(root, file))

locpot_files_exact.sort()

print(locpot_files_exact)

for count,f_cube in enumerate(locpot_files_exact):
  
  fid_name = f_cube.replace("LOCPOT.cube", "")
  #print(fid_name)
 
  #test_file = fid_name+'avez.txt'

  #if os.path.exists(test_file):

  #  data = np.loadtxt(test_file)

  #else:

  data, atoms=read_cube_data(f_cube)

  ave_z_data = np.mean(data, axis=(0, 1))
  index = np.arange(len(ave_z_data))
  index_with_ave_z_data = np.column_stack((index, ave_z_data))

  np.savetxt(fid_name+'/avez.txt',index_with_ave_z_data)
 

  if count==0:
    sum_data=data
  else:
    sum_data=sum_data+data
 
  print("\rcomplete percentage:{0}% ".format(count*100/len(locpot_files_exact)), end="", flush=True)   

ave_data = sum_data/len(locpot_files_exact)

# 计算第一个维度（0）和第二个维度（1）的平均值
mean_of_first_two_dims = np.mean(ave_data, axis=(0, 1))
index = np.arange(len(mean_of_first_two_dims))
new_data = np.column_stack((index, mean_of_first_two_dims))

np.savetxt('avez_all.txt',new_data)



