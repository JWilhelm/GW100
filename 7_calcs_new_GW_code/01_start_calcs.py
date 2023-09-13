import os
import shutil

# Define the source directory for the GW.inp file
source_gw_inp = "../6_GW_input_template_and_reference_for_new_GW_code/GW.inp"  

# Define the target directory where you want to copy the .xyz files
struc_dir = "../1_struc"  # Replace with the actual path

# Iterate over all .xyz files in the source directory
for root, dirs, files in os.walk(struc_dir):
    for file in files:
        if file.endswith(".xyz"):
            # Create a directory with the name of the .xyz file without the extension
            struc_name = os.path.splitext(file)[0]

            # Create the directory if it doesn't exist
            os.makedirs(struc_name, exist_ok=True)

            # Copy the xyz file into the directory
            shutil.copy(os.path.join(root,file), struc_name)

            # Copy the GW.inp file into the directory
            shutil.copy(source_gw_inp, os.path.join(struc_name, "GW.inp"))

            # Read the contents of the .xyz file
            with open(os.path.join(struc_name, "GW.inp"), "r") as xyz_file:
                xyz_content = xyz_file.read()

            replaced_content = xyz_content.replace("<geo>", file)

            # Write the modified content back to the .xyz file
            with open(os.path.join(struc_name, "GW.inp"), "w") as modified_xyz_file:
                modified_xyz_file.write(replaced_content)
