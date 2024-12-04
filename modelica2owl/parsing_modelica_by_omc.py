import logging
logging.basicConfig(level=logging.DEBUG, filename="LOGGING.txt", filemode="w", encoding="utf-8")

def raiseifnot(cond, msg="", exc=AssertionError):
    if not cond:
        raise exc(msg)

class P():
    def __init__(self, logg = False, err = False):
        self.logg = logg
        self.err = err
    def __lt__(self,other):
        if not self.logg and not self.err: print(other)
        elif self.logg: logging.debug(str(other))
        elif self.err: raise TypeError(f"Gonna stop here. Last print >>>{str(other)}<<<")
    def __call__(self,argument = "stop here"):
        if self.err: raise TypeError(f"Gonna stop here. Last print >>>{argument}<<<")
        else: raise TypeError("Wrong use")
p=P(); l=P(logg=True); s=P(err=True)

import json
from rdflib import Graph as Gr
from rdflib.namespace import RDF, RDFS, OWL
from OMPython import OMCSessionZMQ
from parsing_modelica_by_hand import clean_modelica_code

BASIC_MODELICA_TYPES = [
    "Real", 
    "Integer", 
    "String", 
    "Boolean",
    ]


# necessary hack to import config.py when running script regardless of the working directory
import sys, os
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.dirname(SCRIPT_DIR))

from config import MODELICA_EXAMPLE_URL, MODELICA_EXAMPLE_NAMESPACE as EX, DOLCE_IS_PART, DOLCE_HAS_PART, DOLCE_NAMESPACE, DOLCE_URL

from owlready2 import *
DOLCE_ONTO = get_ontology(DOLCE_URL)

def getClassNamesOf(class_name: str, omc: OMCSessionZMQ) -> list[str]:
    return list(omc.sendExpression(f"getClassNames({class_name})"))
def getClassTypeOf(class_name: str, omc: OMCSessionZMQ) -> str:
    return omc.sendExpression(f"getClassInformation({class_name})")[0]
def getDefinedClassesTypesNamesOf(class_name: str, omc: OMCSessionZMQ) -> list[tuple[str]]:
    def_class_names = list(omc.sendExpression(f"getClassNames({class_name})"))
    return [(getClassTypeOf(class_name+"."+def_class_name, omc), def_class_name) for def_class_name in def_class_names] 
def getIndirectSubclasseNamesOf(class_name: str, omc: OMCSessionZMQ) -> list[str]:
    """Returns non-self subclasses. Note that transitivity is takend into account because getAllSubtypeOf is recursive"""
    subclass_names = list(omc.sendExpression(f"getAllSubtypeOf({class_name})"))
    if class_name in subclass_names: subclass_names.remove(class_name)
    return subclass_names
def getPackagesNamesOf(class_name: str, omc: OMCSessionZMQ) -> list[str]:
    return list(omc.sendExpression(f"getPackages({class_name})"))
def getComponentsTypeNameOf(class_name: str, omc: OMCSessionZMQ) -> list[tuple[str]]:
    try:
        p<(1,"class_name:", class_name)
        #components_data = omc.sendExpression("getComponents("+class_name+")") #<- bugged in first model found --> It was solved in commit --> Nope it still fails
        
        raw_components_data = omc.getComponents(class_name)
        p<raw_components_data
        components_data = re.findall(r"\{([A-Z]\w*),\s*(\w+),", raw_components_data) # <-for now needs to parse raw output in a shaky way; the issue is that OMPython cannot deal with expresssions in array subscripts. I opened an issue on git
        # if class_name.endswith("Data_Tables_LAS"): 
        p<components_data
        #     s()
    except Exception as e:
        raise AssertionError(f"{e} was raised when invocking getComponents({class_name}). The relevant code is {omc.sendExpression(f'list({class_name})')}")
    p < (2,class_name,components_data)
    if components_data == "Error":
        raise TypeError(f"omc.sendExpression(getComponents({class_name})) got Error")
    return [(component_data[0],component_data[1]) for component_data in components_data]
def isPackage(class_name: str, omc: OMCSessionZMQ) -> bool:
    return list(omc.sendExpression(f"isPackage({class_name})"))

# def parseIsPackegeOutput(output:str) -> list[str]:
#     """E.g. "{Type, Function}" > ['Type', 'Function']"""
#     out = [subpackage.strip() for subpackage in output.replace("{","").replace("}","").strip().split(",")]
#     if len(out) == 1 and out[0] == "": return []
#     else: return out
def get_adjusted_component_type(component_type: str, absolute_class_name: str, omc) -> str:
    if component_type in BASIC_MODELICA_TYPES:
        return component_type
    ct_l = component_type.split(".") #eg LAS_Sim.Blocks.Data_Tables_LAS or Examples.Data_Tables_LAS
    acn_l = absolute_class_name.split(".") #eg LAS_Sim.Examples.TwoAssembly_OneInspection_Station_Control
    top_level_packages = omc.sendExpression("getClassNames()")
    if ct_l[0] in top_level_packages: 
        return component_type
    p<f"qualifyPath(classPath={acn_l[0]}, path={component_type})"
    qualified_component_name = omc.sendExpression(f"qualifyPath(classPath={acn_l[0]}, path={component_type})")
    if qualified_component_name.split(".")[0] in top_level_packages: 
        return qualified_component_name
    else: #eg ct_l = [Examples,Data_Tables_LAS]
        for el in acn_l:
            if el == ct_l[0]:
                ct_l = acn_l[0:acn_l.index(el)] + ct_l  #eg [Examples,Data_Tables_LAS] > [LAS_Sim,Examples,Data_Tables_LAS]
                return ".".join(ct_l)
        raise TypeError(f"I cannot adjust the component type {component_type} give that the absolute name of its parent is {absolute_class_name}")

def qualpath2URL(qualified_path: str) -> str:
    return qualified_path.replace(".","/")
def getDirectExtensions(absolute_def_class_name: str, omc: OMCSessionZMQ) -> list[str]:
    """This is required cause getAllSubtypeOf is bugged and does not return partial classes"""
    json_str = omc.sendExpression(f"getModelInstance({absolute_def_class_name})")
    jsonAST = json.loads(json_str)
    superclasses = []
    if "elements" in jsonAST:
        for element in jsonAST["elements"]:
            if element["$kind"] == "extends":
                superclasses.append(element["baseClass"]["name"])
    l<(absolute_def_class_name, superclasses)
    return superclasses
def iterate_over_class_definitions(class_name, onto, omc: OMCSessionZMQ, curr_imp_path: str = "") -> None:

    def translate_basic_class_to_owl(specialized_type_name:str, absolute_class_name: str, onto, owl_parthood_relation, omc: OMCSessionZMQ) -> None:
        """Adds the absolute name of the model to the ontology, together with subclass taxonomy and partonomy"""
        SpecializedParent=type(specialized_type_name, (Thing,), {"namespace":onto})
        Clazz=type(qualpath2URL(absolute_class_name), (SpecializedParent,), {"namespace":onto})
        for absolute_subclass_name in getIndirectSubclasseNamesOf(absolute_class_name, omc):
            ChildModel=type(qualpath2URL(absolute_subclass_name), (Clazz,), {"namespace":onto})
        # The above getIndirectSubclasseNamesOf, which uses getAllSubtypeOf would be sufficient, however it is bugged
        # the bug is currently solved on 'OpenModelica v1.25.0-dev-205-gcfba3ef690 (64-bit)' (I got them to correct such a bug)
        # however, users with older versions would get buggy code so I keep the following patch
        isPartial = omc.sendExpression(f"isPartial({absolute_class_name})")
        if isPartial:
            # this case is to pach a the deficency of openmodelica getAllSubtypeOf -> 
            # It could be used to replace the use of getAllSubtypeOf altogether, but I would prefer to use the API as much as possible to reduce the size of this codebase, once they patch the bug
            type(qualpath2URL(absolute_class_name), tuple(type(qualpath2URL(abs_superclass_name), (Thing,), {"namespace":onto}) for abs_superclass_name in getDirectExtensions(absolute_class_name,omc)), {"namespace":onto})
        for component_type, component_name in getComponentsTypeNameOf(absolute_class_name, omc):
            adjusted_component_type = get_adjusted_component_type(component_type, absolute_class_name, omc)
            Component = type(qualpath2URL(adjusted_component_type), (Thing,), {"namespace":onto})
            Clazz.is_a.append(owl_parthood_relation.some(Component))

    owl_parthood_relation = get_component_class_relation()
    for def_class_type, def_class_name in getDefinedClassesTypesNamesOf(class_name, omc):
        absolute_def_class_name = curr_imp_path.replace("/",".")+def_class_name
        p<(def_class_type, def_class_name, absolute_def_class_name)
        match def_class_type:
            case "package":
                p<f"I found package with name {def_class_name}, current import path: {curr_imp_path}; now I iterate in {curr_imp_path.replace("/",".")+def_class_name}"
                iterate_over_class_definitions(absolute_def_class_name, onto, omc, curr_imp_path+def_class_name+"/")
            case "model":
                p<f"I found the model {absolute_def_class_name}!"
                translate_basic_class_to_owl("model", absolute_def_class_name, onto, owl_parthood_relation, omc)
            case "connector":
                translate_basic_class_to_owl("connector", absolute_def_class_name, onto, owl_parthood_relation, omc)
            case "record":
                translate_basic_class_to_owl("record", absolute_def_class_name, onto, owl_parthood_relation, omc)
            case "type":
                translate_basic_class_to_owl("type", absolute_def_class_name, onto, owl_parthood_relation, omc)

    for component_type, component_name in getComponentsTypeNameOf(class_name, omc):
        p<(component_type, component_name, "This will be ignored")
        l<(component_type, component_name, "This will be ignored")
        pass # for now, components that are defined in non-(models,connectors,records,types) will be ignored


def get_component_class_relation():
    return type(DOLCE_HAS_PART.fragment, (ObjectProperty,), {"namespace":DOLCE_ONTO})

def save_ontology(onto, out_file: str = "output.owl"):
    onto.save(out_file, format="rdfxml") # “rdfxml”, “ntriples”.

def loading_modelica_resources(abs_lib_path: str, depended_libraries: list[str], omc: OMCSessionZMQ) -> tuple[str, OMCSessionZMQ]:
    try: 
        for abs_dep_lib_path in depended_libraries:
            b = omc.sendExpression(f"loadFile(\"{abs_dep_lib_path}\")")
            if not b: raise TypeError(f"loadFile(\"{abs_dep_lib_path}\") not true: it is {b}!")
        b = omc.sendExpression(f"loadFile(\"{abs_lib_path}\")")
        if not b: raise TypeError(f"loadFile(\"{abs_lib_path}\") not true: it is {b}!")
        # modelica_code = open(abs_lib_path, "rt", encoding=sys.getfilesystemencoding()).read()
        # omc.sendExpression(f"loadString(\"{modelica_code}\")")
    except Exception as e:
        raise AssertionError(f"loadFile(\"{abs_lib_path}\") (or same with {depended_libraries}) did not work returned {e}")
        #raise AssertionError(f"loadString(\"{modelica_code[:300]}...\") did not work returned {e}")
    file_name = os.path.basename(abs_lib_path)[:-3] 
    # assert omc.loadFile(abs_lib_path), f"omc.loadFile({abs_lib_path}) did not work: returned {omc.loadFile(abs_lib_path)}"
    top_level_names = list(omc.sendExpression("getClassNames()"))
    #class_name=top_level_names[0]#assert len(top_level_names) == 1 and (class_name:=top_level_names[0]) == file_name, f"Actual class name ({class_name}) is different from file name ({file_name})"
    return omc #class_name, omc

def generate_ontology_from_library(abs_out_file_path: str, omc: OMCSessionZMQ, ontology_url: str = MODELICA_EXAMPLE_URL):
    p<f"generating ontology from library..."
    ONTO = get_ontology(ontology_url)
    class_name = list(omc.sendExpression("getClassNames()"))[0] 
    
    # annotate ontology with local time
    from datetime import datetime, timezone
    local_t = datetime.now(timezone.utc).astimezone().isoformat()
    local_tzone = datetime.now(timezone.utc).astimezone().tzinfo
    ONTO.metadata.comment.append(f"Ontology generate from script {__file__} on date {local_t} - {local_tzone}")
    
    Type = type("type", (Thing,), {"namespace":ONTO})
    type("enumeration", (Type,), {"namespace":ONTO})
    for basic_type in BASIC_MODELICA_TYPES:
        type(basic_type, (Type,), {"namespace":ONTO})
    raiseifnot(omc.isPackage(class_name), f"{class_name} should be a package!")
    iterate_over_class_definitions(class_name, ONTO, omc, curr_imp_path=class_name+"/")
    
    save_ontology(ONTO, abs_out_file_path)

def get_total_instatiation_AST(class_name: str, omc: OMCSessionZMQ) -> dict:
    """Returns an Abstract Syntax Tree considering extension and redeclaration constructs, 
    Given a string containing modelica class name and a omc session already containing the appropriate libraries that the code depends on.
    Makes use of the 'getModelInstance' OpenModelica scripting function."""
    AST = json.loads(omc.sendExpression(f"getModelInstance({class_name})"))
    return AST
# these two functions recursively navigate the AST obtained by the OpenModelica compiler function omc.sendExpression("getModelInstance(myProcRes)") 
def visit_root_node(Node, g: Gr, ignore_parameters: bool = True):
    component_disambiguation_idx=[]
    g.add3 = lambda x,y,z : g.add((x,y,z)) # shortens the writing
    g.add3(DOLCE_HAS_PART, RDF.type, OWL.ObjectProperty)
    
    if not isinstance(Node, dict):
        raise TypeError(f"A node of the wrong type has been passed! I was expecting dict, I got {type(Node)}")
    
    modelName = Node["name"] + "_0"
    modelClassName = qualpath2URL(Node["name"])
    restriction = Node["restriction"]
    g.add3(EX[modelName], RDF.type, EX[modelClassName])
    g.add3(EX[modelClassName], RDFS.subClassOf, EX[restriction])
    
    elab_elements_(Node, EX[modelName], component_disambiguation_idx, g, ignore_parameters)
    # elements = Node["elements"] if "elements" in Node else []
    ###rootNode = EX[modelName]
    # for el in elements:
    #     match el["$kind"]:
    #         case "extends":
    #             if isinstance(el["baseClass"], str):
    #                 superType = qualpath2URL(el["baseClass"])
    #             else:
    #                 superType = qualpath2URL(el["baseClass"]["name"])
    #                 visit_node_and_build_component_type_graph(el["baseClass"],EX[modelName],component_disambiguation_idx,g)
    #             g.add3(EX[modelName], RDF.type, EX[superType])
    #         case "component":
    #             componentName = modelName.replace("/",".") + "." + el["name"] + "_" + str(len(component_disambiguation_idx))
    #             component_disambiguation_idx.append(1)
    #             if restriction == "type" and "type" not in el: 
    #                 # eg el is an enumeration element eg {'$kind': 'component', 'name': 'idle'}. In this case for now I dont do anyything
    #                 continue
    #             componentType = el["type"]
    #             g.add3(EX[modelName], DOLCE_HAS_PART, EX[componentName])
    #             if isinstance(componentType, str):
    #                 g.add3(EX[componentName], RDF.type, EX[componentType.replace(".", "/")])
    #             else: # in this case componentType is a dict containing name for supertype name and elements  
    #                 g.add3(EX[componentName], RDF.type, EX[componentType["name"].replace(".", "/")])
    #                 visit_node_and_build_component_type_graph(componentType,EX[componentName],component_disambiguation_idx,g)

def visit_node_and_build_component_type_graph(Node, rootNode, component_disambiguation_idx, g, ignore_parameters):
    if not isinstance(Node, (dict)):
        raise TypeError(f"A node of the wrong type has been passed! I was expecting dict, I got {type(Node)}")
    
    modelName: str = qualpath2URL(Node["name"])
    restriction: str = Node["restriction"]
    g.add3(EX[modelName], RDFS.subClassOf, EX[restriction])

    elab_elements_(Node, rootNode, component_disambiguation_idx, g, ignore_parameters)

def elab_elements_(Node, rootNode, component_disambiguation_idx: list, g, ignore_parameters):
    modelName = qualpath2URL(Node["name"])
    elements = Node["elements"] if "elements" in Node else []
    for el in elements:
        match el["$kind"]:
            case "extends":
                if isinstance(el["baseClass"], str):
                    superType = qualpath2URL(el["baseClass"])
                else:
                    superType = qualpath2URL(el["baseClass"]["name"])
                    visit_node_and_build_component_type_graph(el["baseClass"],rootNode,component_disambiguation_idx,g,ignore_parameters)
                g.add3(EX[modelName], RDFS.subClassOf, EX[superType])
            case "component":
                if Node["restriction"] == "type" and "type" not in el: 
                    # eg el is an enumeration element eg {'$kind': 'component', 'name': 'idle'}. In this case for now I dont do anyything
                    continue
                if isinstance(el["type"], str):
                    ##  here no need to filter: the class is always a specialization of modelica's type (e.g. Real, Integer, Boolean, String)
                    if not ignore_parameters:
                    # if EX["type"] not in g.transitive_objects(EX[componentType], RDFS.subClassOf):
                    #     component_disambiguation_idx.append(1)
                        componentType = qualpath2URL(el["type"])
                        componentName = modelName.replace("/",".") + "." + el["name"] + "_" + str(len(component_disambiguation_idx))
                        g.add3(EX[componentName], RDF.type, EX[componentType])
                        g.add3(rootNode, DOLCE_HAS_PART, EX[componentName])
                else: # in this case componentType is a dict containing name for supertype name and elements  
                    componentType = qualpath2URL(el["type"]["name"])
                    # here I filter out any parameter whose class is a specialization of modelica's type (e.g. Real, Integer, Boolean, String, enumeration)
                    # However, note that not all such classes will be filtered out, eg the first Seed parameter is not because the graph does not know yet that it is a subclass fo type (the second already is eliminated)
                    # therefore, an additional removal step is carried out after the recursive visit
                    if EX["type"] not in g.transitive_objects(EX[componentType], RDFS.subClassOf) or not ignore_parameters:
                        component_disambiguation_idx.append(1)
                        componentName = modelName.replace("/",".") + "." + el["name"] + "_" + str(len(component_disambiguation_idx))
                        g.add3(EX[componentName], RDF.type, EX[componentType])
                        g.add3(rootNode, DOLCE_HAS_PART, EX[componentName])
                        visit_node_and_build_component_type_graph(el["type"],EX[componentName],component_disambiguation_idx,g,ignore_parameters)
                        # the additional removal step is carried out after the recursive visit
                        if EX["type"] in g.transitive_objects(EX[componentType], RDFS.subClassOf) and ignore_parameters:
                            g.remove((EX[componentName], None, None))
                            g.remove((None, None, EX[componentName]))

if __name__ == "__main__":

    ABSOLUTE_PATH_OF_PROJECT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    library_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"modelica_files\\LAS_Sim.mo")
    simplified_library_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"modelica_files\\LAS_Sim_simplified.mo")
    open(simplified_library_abs_path, "w", encoding="utf-8").write(clean_modelica_code(open(library_abs_path, encoding="utf-8").read()))
    #library_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"modelica_files\\DSML.mo")
    random_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"modelica_files\\Random.mo")
    ontology_from_library_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"ontologies\\ontology_generated_from_library.owl")
    #ontology_from_library_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"ontologies\\DSML-gen.owl")
    user_modelica_model_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"modelica_files\\myProcRes.mo")
    user_model_plus_library_ontology_abs_path = os.path.join(ABSOLUTE_PATH_OF_PROJECT,"ontologies\\individual_plus_library.owl")
    libraries_needed_by_user_model = [library_abs_path]
    user_model_qualified_path = "LAS_Sim.Examples.TwoAssembly_OneInspection_Station_Control"

    # json.dump(get_total_instatiation_AST(library_abs_path, [random_abs_path]), open("ast.json", "wt"))
    # s()
    omc = OMCSessionZMQ()
    omc = loading_modelica_resources(simplified_library_abs_path, depended_libraries = [random_abs_path], omc = omc)
    
    # generate_ontology_from_library(ontology_from_library_abs_path, omc, ontology_url=MODELICA_EXAMPLE_URL)
    # s(f"produced {ontology_from_library_abs_path}")
    
    g=Gr()
    g.bind("md", EX)
    g.bind("dl", DOLCE_NAMESPACE)
    g.parse(ontology_from_library_abs_path)
    # st = g.serialize(); print(st); s()
    
    AST = json.loads(omc.sendExpression(f"getModelInstance({user_model_qualified_path})"))
    # AST = get_total_instatiation_AST(user_modelica_model_abs_path, libraries_needed_by_user_model)
    # l<"\n"*10
    # l<AST
    visit_root_node(AST, g)
    from pprint import pprint as pp
    st = g.serialize()
    print("Last 1000 chars of graph, now in clipboard: ", st[len(st)-1000:])
    fo=open(user_model_plus_library_ontology_abs_path, "wt", encoding=sys.getdefaultencoding())
    fo.write(st); fo.close()
    import pyperclip
    pyperclip.copy(st)
    