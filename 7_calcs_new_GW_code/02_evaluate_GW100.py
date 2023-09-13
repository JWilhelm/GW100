import os
import shutil
import subprocess
import re

reference_homos_lumos = "../6_GW_input_template_and_reference_for_new_GW_code/GW_reference.dat"
excluded_homos = "./6_GW_input_template_and_reference_for_new_GW_code/excluded_HOMOs.dat"

# Define the target directory where you want to copy the .xyz files
struc_dir = "../1_struc"  # Replace with the actual path

# Iterate over all .xyz files in the source directory
for root, dirs, files in os.walk(struc_dir):
    for file in files:
        if file.endswith(".xyz"):

            struc_name = os.path.splitext(file)[0]

            with open(os.path.join(struc_name, "cp2k.out"), "r") as cp2k_outfile:
               for line in cp2k_outfile:
                   split_line = line.split()

                   if len(split_line) > 3:
                      if split_line[0] == "G0W0" and split_line[1] == "valence":
                         homo = float(split_line[5])
                         print(struc_name+", HOMO = ", homo, " eV")
           

