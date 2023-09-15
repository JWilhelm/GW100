import os
import shutil
import subprocess
import re

reference_homos_lumos = "../../6_GW_input_template_and_reference_for_new_GW_code/GW_reference.dat"
excluded_homos = "../../6_GW_input_template_and_reference_for_new_GW_code/excluded_HOMOs.dat"

# Define the target directory where you want to copy the .xyz files
struc_dir = "../../1_struc"  # Replace with the actual path

# Iterate over all .xyz files in the source directory
for root, dirs, files in os.walk(struc_dir):
    for file in files:
        if file.endswith(".xyz"):

            struc_name = os.path.splitext(file)[0]

            found = False       

            with open(os.path.join(struc_name, "cp2k.out"), "r") as cp2k_outfile:
               for line in cp2k_outfile:
                   split_line = line.split()

                   if len(split_line) > 3:
                      if split_line[0] == "G0W0" and split_line[1] == "valence":
                         homo = float(split_line[5])
                         found = True           

                      if split_line[0] == "G0W0" and split_line[1] == "conduction":
                         lumo = float(split_line[5])


            with open(reference_homos_lumos, "r") as ref_file:
               for line in ref_file:
                   split_line = line.split()

                   if split_line[0] == struc_name:
                       homo_ref = float(split_line[1])
                       lumo_ref = float(split_line[2])


            if found:
               print(struc_name+", HOMO = ", homo, ", HOMO ref =", homo_ref, \
                                ", LUMO = ", lumo, ", LUMO ref =", lumo_ref)   
            else:
               print(struc_name+" not found")
