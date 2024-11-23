MODELICA_EXAMPLE_URL = "http://modelica_example/"
DOLCE_URL = "https://w3id.org/DOLCE/OWL/DOLCEbasic#"

from rdflib import Namespace
DOLCE_NAMESPACE = Namespace(DOLCE_URL)
DOLCE_IS_PART = DOLCE_NAMESPACE["constantPartOf"]
DOLCE_HAS_PART = DOLCE_NAMESPACE["hasConstantPart"]
MODELICA_EXAMPLE_NAMESPACE = Namespace(MODELICA_EXAMPLE_URL)

ABSOLUTE_OPENMODELICA_CLI_PATH = r"C:\Program Files\OpenModelica1.24.0-64bit\bin\omc"
ABSOLUTE_OPENMODELICA_MODEL_PATH = r"C:\Users\Francesco\Desktop\Work_Units\modelica_constraints\modelica_files\myProcRes.mo"
ABSOLUTE_FLATTENED_MODEL_PATH = r"C:\Users\Francesco\Desktop\Work_Units\modelica_constraints\modelica_files\flattened.mo"

required_libraries = [r"C:\Users\Francesco\Desktop\Work_Units\modelica_constraints\modelica_files\DSML.mo"]
