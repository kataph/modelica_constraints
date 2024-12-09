import argparse
parser = argparse.ArgumentParser(
                    prog='modelica_constraint',
                    description='Checks a modelica model against constraints. Example call: $python main.py LAS_Sim LAS_Sim.Examples.TwoAssembly_OneInspection_Station_Control -d Random -d Dependency2 -d Dependency3 -tg --keep_parameters. The T-Box ontology will appear in ontologies\\ontology_generated_from_{LIBRARY_NAME.replace(".","_")}.owl"), while the individual partonomy in ontologies\\{USER_MODEL_QUALIFIED_PATH.replace(".","_")}_plus_{LIBRARY_NAME.replace(".","_")}.owl',
                    epilog='__________________________________')

class CustomAppendAction(argparse.Action):
    """Custom action to append values to a list.

    When using the `append` action, the default value is not removed
    from the list. This problem is described in
    https://github.com/python/cpython/issues/60603

    This custom action aims to fix this problem by removing the default
    value when the argument is specified for the first time.
    """

    def __init__(self, option_strings, dest, nargs=None, **kwargs):
        """Initialize the action."""
        self.called_times = 0
        self.default_value = kwargs.get("default")
        print(dest)
        print(option_strings)
        super().__init__(option_strings, dest, **kwargs)

    def __call__(self, parser, namespace, values, option_string=None):
        """When the argument is specified on the commandline."""
        print(namespace)
        print(values)
        current_values = getattr(namespace, self.dest)

        if self.called_times == 0 and current_values == self.default_value:
            current_values = []

        current_values.append(values)
        setattr(namespace, self.dest, current_values)
        self.called_times += 1


parser.add_argument('library_name', default="LAS_Sim", help="Name of the modelica library file name (without .mo; file must end with .mo extension; the file must be located in the modelica_constraints\\modelica_files\\ folder) to be used for ontology generation. Default LAS_Sim")
parser.add_argument('user_model', default="LAS_Sim.Examples.TwoAssembly_OneInspection_Station_Control", help="Completely qualified path of the user model within the library. Defaults to 'LAS_Sim.Examples.TwoAssembly_OneInspection_Station_Control'. It is assumed the user model is part of the library file, e.g. in Root.Examples.User_model")
parser.add_argument('-d', '--dependencies', action="extend", nargs='+', default=[], help="List of libraries the first library file depend on. Defaults to []. (for each file: the argument must end without .mo, while the file must end with .mo extension; the file must be located in the modelica_constraints\\modelica_files\\ folder)")
# parser.add_argument('-d', '--dependencies', action="extend", nargs='+', default=["Random"])      # option that takes a value
parser.add_argument('-tg', '--tbox_generation', action='store_true', help="Generates also the T-Box. If this flag is not set, the script will search for a 'ontologies\\ontology_generated_from_{LIBRARY_NAME}.owl' file. Not finding it will return an error")  # on/off flag
parser.add_argument('-kp', '--keep_parameters', action='store_true', help="Keeps also modelica types in the partonomy (e.g. Integer, Real, Boolean, String, enumeration, ... and their specializations): each model parameter will be rapresented by an individual in the partonomy. If not set, they will be ignored")  # on/off flag

args = parser.parse_args()
LIBRARY_NAME: str = args.library_name
DEPENDENCES: list[str] = args.dependencies
USER_MODEL_QUALIFIED_PATH: str = args.user_model
TBOX_GENERATION: bool = args.tbox_generation
KEEP_PARAMETERS: bool = args.keep_parameters

from modelica2owl.parsing_modelica_by_omc import *

ABSOLUTE_PATH_OF_PROJECT = os.path.dirname(os.path.abspath(__file__))
print(f"absolute path of the project is {ABSOLUTE_PATH_OF_PROJECT}")
library_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"modelica_files",f"{LIBRARY_NAME}.mo")
simplified_library_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"modelica_files",f"{LIBRARY_NAME}_simplified.mo")
depended_libraries = [os.path.join(ABSOLUTE_PATH_OF_PROJECT,"modelica_files",f"{dependence}.mo") for dependence in DEPENDENCES]
ontology_from_library_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"ontologies",f"ontology_generated_from_{LIBRARY_NAME.replace(".","_")}.owl")
user_model_plus_library_ontology_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"ontologies",f"{USER_MODEL_QUALIFIED_PATH.replace(".","_")}_plus_{LIBRARY_NAME.replace(".","_")}.owl")

if sys.platform.startswith("win"):
    library_abs_path = library_abs_path.replace("\\","\\\\")
    simplified_library_abs_path = simplified_library_abs_path.replace("\\","\\\\")
    depended_libraries = [depended_library.replace("\\","\\\\") for depended_library in depended_libraries]

# This will remove annotations and save a corresponding file
open(simplified_library_abs_path, "w", encoding="utf-8").write(clean_modelica_code(open(library_abs_path, encoding="utf-8").read()))

# loading Open Modelica Compiler
omc = OMCSessionZMQ()
omc = loading_modelica_resources(simplified_library_abs_path, depended_libraries = depended_libraries, omc = omc)

# generating T-Box (Class-level) ontology
if TBOX_GENERATION:
    generate_ontology_from_library(ontology_from_library_abs_path, omc, ontology_url=MODELICA_EXAMPLE_URL)
else:
    print("Skipping T-Box generation...")

# generating (A-Box) instance-level partonomy
g=Gr()
g.bind("md", EX)
g.bind("dl", DOLCE_NAMESPACE)
g.parse(ontology_from_library_abs_path)
print("Starting individual model generation...")
AST = json.loads(omc.sendExpression(f"getModelInstance({USER_MODEL_QUALIFIED_PATH})"))
visit_root_node(AST, g, (IGNORE_PARAMETERS:=not KEEP_PARAMETERS))
st = g.serialize(destination=user_model_plus_library_ontology_abs_path, encoding=sys.getdefaultencoding())
print(f"written ontology with individual model at {user_model_plus_library_ontology_abs_path}")