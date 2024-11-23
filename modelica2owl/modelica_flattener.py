import subprocess

# necessary hack to import config.py when running script regardless of the working directory
import sys, os
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.dirname(SCRIPT_DIR))

from config import ABSOLUTE_OPENMODELICA_CLI_PATH, ABSOLUTE_OPENMODELICA_MODEL_PATH, ABSOLUTE_FLATTENED_MODEL_PATH, required_libraries

#subprocess.run(["dir"], shell=True)
def get_flattened_model():
    subprocess.run([ABSOLUTE_OPENMODELICA_CLI_PATH, ABSOLUTE_OPENMODELICA_MODEL_PATH] + required_libraries, stdout=open(ABSOLUTE_FLATTENED_MODEL_PATH, "wt"), shell=True)
    return open(ABSOLUTE_FLATTENED_MODEL_PATH, "rt").read()
def get_model():
    return open(ABSOLUTE_OPENMODELICA_MODEL_PATH, "rt").read()




