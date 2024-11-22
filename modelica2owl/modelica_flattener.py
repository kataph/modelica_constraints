import subprocess

ABSOLUTE_OPENMODELICA_CLI_PATH = r"C:\Program Files\OpenModelica1.24.0-64bit\bin\omc"#r"'%OPENMODELICAHOME%bin\omc'" <- no variables
ABSOLUTE_OPENMODELICA_MODEL_PATH = r"C:\Users\Francesco\Desktop\Work_Units\Sergio\modelica_files\myProcRes.mo"
ABSOLUTE_FLATTENED_MODEL_PATH = r"C:\Users\Francesco\Desktop\Work_Units\Sergio\modelica_files\flattened.mo"

required_libraries = [r"C:\Users\Francesco\Desktop\Work_Units\Sergio\modelica_files\DSML.mo"]

#subprocess.run(["dir"], shell=True)
def get_flattened_model():
    subprocess.run([ABSOLUTE_OPENMODELICA_CLI_PATH, ABSOLUTE_OPENMODELICA_MODEL_PATH] + required_libraries, stdout=open(ABSOLUTE_FLATTENED_MODEL_PATH, "wt"), shell=True)
    return open(ABSOLUTE_FLATTENED_MODEL_PATH, "rt").read()
def get_model():
    return open(ABSOLUTE_OPENMODELICA_MODEL_PATH, "rt").read()




