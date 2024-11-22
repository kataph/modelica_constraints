

import modparc
from rdflib import Graph as Gr, Namespace as NameSp, URIRef, Literal
from rdflib.namespace import RDF, RDFS
from OMPython import OMCSessionZMQ, ModelicaSystem
    
import types
MODELICA_ONTO_NAMESPACE = "http://test.org/"
from owlready2 import *
ONTO = get_ontology(MODELICA_ONTO_NAMESPACE)

from modelica_flattener import get_flattened_model, get_model, ABSOLUTE_OPENMODELICA_MODEL_PATH

se=['Expression', 'SimpleExpression', 'LogicalExpression',
           'LogicalTerm', 'LogicalFactor', 'Relation',
           'ArithmeticExpression', 'Term', 'Factor', 'Primary', 'RelOp',
           'MulOp', 'AddOp', 'Name', 'NamedArgument', 'NamedArguments',
           'FunctionArgument', 'FunctionArguments', 'FunctionCallArgs',
           'ExpressionList', 'OutputExpressionList', 'Subscript',
           'ArraySubscript', 'ComponentReference', 'StringComment',
           'Annotation', 'Comment', "LanguageSpecification", "BasePrefix",
           "ExternalFunctionCall", "Element", "ElementList",
           "Composition", "ClassSpecifier", "ClassPrefixes",
           "EnumerationLiteral", "EnumList", "ImportList", "ImportClause",
           "TypePrefix", "TypeSpecifier", "ConditionAttribute", "Declaration",
           "ComponentDeclaration", "ComponentList", "ComponentClause",
           "ForIndex", "ForIndices", "ConnectClause", "Equation", "IfEquation",
           "ForEquation", "WhileEquation", "WhenEquation", "Statement",
           "IfStatement", "ForStatement", "WhileStatement", "WhenStatement",
           "EquationSection", "AlgorithmSection", "ExtendsClause",
           "ConstrainingClause", "Modification", "ShortClassDefinition",
           "ComponentDeclaration1", "ComponentClause1", "ElementReplaceable",
           "ElementRedeclaration", "ElementModification",
           "ElementModificationOrReplaceable", "Argument", "ArgumentList",
           "ClassModification", "Assertion"]

me=['class_type',#n
 'code',
 'elements',#tuple
 'find',
 'name',#n
 'original_code',
 'prefix', #n
 'search']

def get_first_extends(model_definition):
    return model_definition.search("ExtendsClause")[0].search("Name")[0].search("Token")[0].name
def get_all_extends(model_definition):
    return [x.search("Name")[0].search("Token")[0].name for x in model_definition.search("ExtendsClause")]
def get_ith_extends(model_definition, idx):
    if idx not in range(len(se:=model_definition.search("ExtendsClause"))):
        raise TypeError(f"Input idx={idx} is out of admissible range = 0..{len(se)-1} ")
    return se[idx].search("Name")[0].search("Token")[0].name

def get_first_equation_code(model_definition):
    return model_definition.search('Equation')[0].code()
def get_all_equations_codes(model_definition):
    return [x.code() for x in model_definition.search('Equation')]

def get_all_components_type_name(model_definition):
    # .search("Token")[-1].name --> Ports.>DataPort<, .search("Token")[].name --> Ports, .search("Token").code() --> Ports.DataPorts
    return [(x.search("Name")[0].search("Token")[-1].name, x.search("Declaration")[0].search("Token")[0].name) for x in model_definition.search("ComponentClause")]
def get_all_element_modifications_of_component_from_type_and_index(model_definition, component_name_type, idx):
    se = model_definition.search("ComponentClause")
    type_names = map(lambda x: x.search("Name")[0].search("Token")[0].name, se)
    matching_type_names = [(i,t) for i,t in enumerate(type_names) if t == component_name_type]
    if idx not in range(len(matching_type_names)):
        raise TypeError(f'''There are {len(matching_type_names)} components of type {component_name_type},
                         but Input idx={idx} is out of admissible range = 0..{len(matching_type_names)-1}''')
    i,_ = matching_type_names[idx]
    key = se[i].search("Declaration")[0].search("Token")[0].name
    modifications = se[i].search("Declaration")[0].search("ElementModification")
    return {key:[(modification.search("Name")[0].search("Token")[0].name, modification.search("Expression")[0].code()) for modification in modifications]}
def get_type_and_modifications_from_component_name(model_definition, component_name):
    se:list = model_definition.search("ComponentClause")
    component = [x for x in se if x.search("Declaration")[0].search("Token")[0].name == component_name].pop()
    key = component.search("Name")[0].search("Token")[0].name
    modifications = component.search("Declaration")[0].search("ElementModification")
    return {key:[(modification.search("Name")[0].search("Token")[0].name, modification.search("Expression")[0].code()) for modification in modifications]}

def get_description_name(model_definition):
    return model_definition.name()
def get_description_prefix(model_definition):
    return model_definition.prefix() # returns full prefix eg partial model
def get_description_type(model_definition):
    return model_definition.prefix().split(" ")[-1] # returns full prefix eg partial model
def get_model_base_classes(model_definition):
    return get_all_extends(model_definition)
def get_model_children(model_definition):
    return [name for type, name in get_all_components_type_name(model_definition)]

def iterate_over_class_definitions(stored_definition):
    for cl_df in stored_definition.search("ClassDefinition"):
        class_definition_code = cl_df.search("ClassPrefixes")[0].code() # e.g. package or partial model
        last_class_prefix = cl_df.search("ClassPrefixes")[0].search("Token")[-1].name # e.g. package or model
        match last_class_prefix:
            case "package":
                continue
            case "model":
                translate_model_to_owl(cl_df)
            case "connector":
                translate_model_to_owl(cl_df)
            case "record":
                translate_model_to_owl(cl_df)

def get_component_class_relation(component, type):
    return type("has-part", (ObjectProperty,), {"namespace":ONTO})

def translate_model_to_owl(model_definition):
    components_with_types = get_all_components_type_name(model_definition)
    base_classes = get_model_base_classes(model_definition)
    model_name = get_description_name(model_definition)
    model_type = get_description_type(model_definition)
    Base_classes=[]
    for base_class in base_classes:
        ParentModel=type(base_class, (Thing,), {"namespace":ONTO})
        Base_classes.append(ParentModel)
    SpecializedParent=type(model_type, (Thing,), {"namespace":ONTO})
    Base_classes.append(SpecializedParent)
    Model=type(model_name, tuple(Base_classes), {"namespace":ONTO})
    #connects=type("connects", (ObjectProperty,),{"namespace":onto, "domain": [Model], "range": [Model]})
    for c_type, component in components_with_types:
        owl_relation = get_component_class_relation(component, type)
        Component = type(c_type, (Thing,), {"namespace":ONTO})
        #print(Model.is_a)
        Model.is_a.append(owl_relation.some(Component))
        #print(Model.is_a)
        #new_attr = getattr(namespace,HAS_PART).some(getattr(namespace, part.name))
        #setattr(self, "is_a", list(set(new_attr)))
        #s()
        #Model., owl_relation, Component


    print(f"todo ... {model_name} is type {model_type}, it has components {components_with_types} and extends base classes {base_classes} ...")

def translate_flattened_model_to_owl(base_model_definition, flattened_model_definition):
    components_with_types = get_all_components_type_name(flattened_model_definition)
    base_classes = get_model_base_classes(base_model_definition)
    model_name = get_description_name(base_model_definition)
    model_type = get_description_type(base_model_definition)

    Base_classes=[]
    for base_class in base_classes:
        ParentModel=type(base_class, (Thing,), {"namespace":ONTO})
        Base_classes.append(ParentModel)
    SpecializedParent=type(model_type, (Thing,), {"namespace":ONTO})
    Base_classes.append(SpecializedParent)
    Model=type(model_name, tuple(Base_classes), {"namespace":ONTO})
    for c_type, component in components_with_types:
        owl_relation = get_component_class_relation(component, type)
        Component = type(c_type, (Thing,), {"namespace":ONTO})
        Model.is_a.append(owl_relation.some(Component))

    print(f"todo ... {model_name} is type {model_type}, it has components {components_with_types} and extends base classes {base_classes} ...")

def save_ontology():
    ONTO.save("output.owl", format="rdfxml") # “rdfxml”, “ntriples”.

def get_total_instatiation_CST(file_path: str, depended_libraries: list[str]) -> dict:
    """Returns a Concrete Syntax Tree considering extension and redeclaration constructs, 
    Given a .mo modelica absolute file path and a list containing the absolute paths of the library-files the file depends on.
    Makes use of the 'getModelInstance' OpenModelica scripting function."""
    
    file_name = file_path.split("/")[-1].split("\\")[-1].split('.')[-2]
    assert file_path[-3:] == ".mo", f"Path does not terminate with '.mo'. File name is {file_name}"
    model_description = modparc.parse(open(file_path, "rt").read())
    model_name = get_description_name(model_description)
    assert model_name == file_name, f"Actual model name ({model_name}) is different from file name ({file_name})"
    
    omc = OMCSessionZMQ()
    assert omc.loadFile(file_path), f"omc.loadFile({file_path}) did not work: returned {omc.loadFile(file_path)}"
    for lib_path in depended_libraries:
        omc.loadFile(lib_path)
        assert omc.loadFile(lib_path), f"omc.loadFile({lib_path}) did not work: returned {omc.loadFile(lib_path)}"
    CST = json.loads(omc.sendExpression(f"getModelInstance({model_name})"))
    return CST
# these two functions recursively navigate the CST obtained by the OpenModelica compiler function omc.sendExpression("getModelInstance(myProcRes)") 
def visit_root_node(Node, g):
    if not isinstance(Node, dict):
        raise TypeError(f"A node of the wrong type has been passed! I was expecting dict, I got {type(Node)}")
    modelName = Node["name"]
    restriction = Node["restriction"]
    g.add3(EX[modelName], RDF.type, EX[restriction])
    elements = Node["elements"] if "elements" in Node else []
    for el in elements:
        match el["$kind"]:
            case "extends":
                superType = el["baseClass"]["name"]
                visit_node_and_build_component_type_graph(el["baseClass"],EX[modelName],[1],g)
                g.add3(EX[modelName], RDF.type, EX[superType])
            case "component":
                componentName = modelName + "." + el["name"]
                componentType = el["type"]
                g.add3(EX[modelName], DOLCE["has-part"], EX[componentName])
                g.add3(EX[componentName], RDF.type, EX[componentType])
def visit_node_and_build_component_type_graph(Node, rootNode, component_disambiguation_idx, g):
    if not isinstance(Node, (dict)):
        raise TypeError(f"A node of the wrong type has been passed! I was expecting dict, I got {type(Node)}")
    modelName = Node["name"]
    restriction = Node["restriction"]
    g.add3(EX[modelName], RDFS.subClassOf, EX[restriction])
    elements = Node["elements"] if "elements" in Node else []
    for el in elements:
        match el["$kind"]:
            case "extends":
                superType = el["baseClass"]["name"]
                visit_node_and_build_component_type_graph(el["baseClass"],rootNode,component_disambiguation_idx,g)
                g.add3(EX[modelName], RDFS.subClassOf, EX[superType])
            case "component":
                componentName = modelName + "." + el["name"] + "_" + str(len(component_disambiguation_idx))
                component_disambiguation_idx.append(1)
                componentType = el["type"]
                g.add3(rootNode, DOLCE["has-part"], EX[componentName])
                if isinstance(componentType, str):
                    g.add3(EX[componentName], RDF.type, EX[componentType])
                else: # in this case componentType is a dict containing name for supertype name and elements  
                    g.add3(EX[componentName], RDF.type, EX[componentType["name"]])
                    visit_node_and_build_component_type_graph(componentType,EX[componentName],component_disambiguation_idx,g)

if __name__ == "__main__":
    class P():
        def __lt__(self,o):
            print(o)
    p=P()


    import json
    g=Gr()
    EX = NameSp("http://modelica_example.org/")
    DOLCE = NameSp("http://dolce_namespace.org/")
    g.add3 = lambda x,y,z : g.add((x,y,z)) # shortens the writing
    g.bind("md", EX)
    g.bind("dl", DOLCE)
    # g.add3(EX["name"], EX["has_part"], Literal("2"))
    # print(g.serialize()); s()


    CST = get_total_instatiation_CST("C:\\Users\\Francesco\\Desktop\\Work_Units\\Sergio\\modelica_files\\myProcRes.mo",["C:\\Users\\Francesco\\Desktop\\Work_Units\\Sergio\\modelica_files\\DSML.mo"])
    visit_root_node(CST, g)
    from pprint import pprint as pp
    # pp(v)
    st = g.serialize()
    print(st)
    import pyperclip
    pyperclip.copy(st)
    s()
    # print(CST);s()

    # CST = json.load(open(r"C:\Users\Francesco\Desktop\Work_Units\Sergio\modelica_files\myProcResCST.json", "r"))
    # def visit_tree_and_collect_values(CST: dict, key: str, values: list):
    #     if not isinstance(CST, (dict,list)):
    #         print(f"CST is of type: {type(CST)}")
    #         return
    #     if isinstance(CST, dict):
    #         for k,v in CST.items():
    #             print(f"I am visiting key: {k}")
    #             if k==key: values.append(v)
    #             else: visit_tree_and_collect_values(v, key, values)
    #     if isinstance(CST, list):
    #         for el in CST: visit_tree_and_collect_values(el, key, values)
    # def visit_tree_and_collect_components(CST: dict, values: list):
    #     if not isinstance(CST, (dict,list)):
    #         print(f"CST is of type: {type(CST)}, exiting...")
    #         return
    #     if isinstance(CST, dict):
    #         for k,v in CST.items():
    #             print(f"I am visiting key: {k}")
    #             if v=="component": values.append(CST)
    #             else: visit_tree_and_collect_components(v, values)
    #     if isinstance(CST, list):
    #         for el in CST: visit_tree_and_collect_components(el, values)

    # def visit_tree_and_build_component_type_graph(Node, g):
    #     if not isinstance(Node, (dict,list)):
    #         print(f"Node is of type: {type(Node)}, exiting...")
    #         return
    #     if isinstance(Node, dict):
    #         for k,v in Node.items():
    #             print(f"I am visiting key: {k}")
    #             if v=="component": g.append(Node)
    #             else: visit_tree_and_collect_components(v, g)
    #     if isinstance(Node, list):
    #         for el in Node: visit_tree_and_collect_components(el, g)

    
    # v = []
    # visit_tree_and_collect_values(CST, "$kind", v)
    # visit_tree_and_collect_components(CST, v)
    # visit_node_and_build_component_type_graph(CST, g)

    modelica_code = """
    model MyModel
        extends BaseModel1;
        extends BaseModel2;
        Real x;
        Integer y = 10;
        Resistor r(R=1);
        equation
            x = y + 1;
    end MyModel;
    """
    modelica_code2 = """package test

partial class MyOtherModel
    Real y;
    Integer z = 100;
end MyOtherModel;

partial class MyModel
    extends M;
    Real x;
    Integer y = 10;
    equation
        x = y + 1;
end MyModel;

end test;
"""

    base_modelica = """model 'myProcRes'
    Real 'port_1.inp';
    Real 'port_1.out';
    Real 'port_2.inp';
    Real 'port_2.out';
  end 'myProcRes';"""

    # p<get_all_element_modifications_of_component_from_type_and_index(model_definition, "Resistor", 0)
    # p<get_type_and_modifications_from_component_name(model_definition, "r")
    # p<get_all_components_type_name(model_definition)
    # translate_model_to_owl(model_definition)

    #modelica_code3 = open("DSML.mo", "rt").read()
    #model_definition = modparc.parse(modelica_code3)
    #iterate_over_class_definitions(model_definition)
    #save_ontology()

    # from OMPython import OMCSessionZMQ, ModelicaSystem
    # omc = OMCSessionZMQ()

    # print(omc.sendExpression("getVersion()"))
    # # omc.sendExpression("loadModel(Modelica)")
    # omc.sendExpression("loadFile(\"C:\\Users\\Francesco\\Desktop\\Work_Units\\Sergio\\modelica_files\\BouncingBall.mo\")")#"loadFile(getInstallationDirectoryPath() + \"/share/doc/omc/testmodels/BouncingBall.mo\")")
    # # loading library is necessary
    # omc.sendExpression("loadFile(\"C:\\Users\\Francesco\\Desktop\\Work_Units\\Sergio\\modelica_files\\DSML.mo\")")#"loadFile(getInstallationDirectoryPath() + \"/share/doc/omc/testmodels/BouncingBall.mo\")")
    # omc.sendExpression("loadFile(\"C:\\Users\\Francesco\\Desktop\\Work_Units\\Sergio\\modelica_files\\myProcRes.mo\")")#"loadFile(getInstallationDirectoryPath() + \"/share/doc/omc/testmodels/BouncingBall.mo\")")
    # # print(omc.sendExpression("getInstallationDirectoryPath()"))
    # # print(omc.sendExpression("instantiateModel(BouncingBall)"))
    # # print("-->", omc.sendExpression("instantiateModel(DSML)"))
    # print("-->", omc.sendExpression("instantiateModel(myProcRes)"))
    # # print(omc.sendExpression("isPartial(BouncingBall)"))
    # print(omc.sendExpression("isPartial(myProcRes)"))
    # print(omc.sendExpression("isModel(myProcRes)"))
    # # print(omc.sendExpression("getModelInstance(myProcRes)"))
    # print(omc.sendExpression("getModelInstanceAnnotation(myProcRes, prettyPrint=true)"))
    # # print(omc.sendExpression("extendsFrom(BouncingBall)"))

    # s()
    # # mod=ModelicaSystem(r"C:\\Users\\Francesco\\Desktop\\Work_Units\\Sergio\\modelica_files\\BouncingBall.mo","BouncingBall")
    # mod=ModelicaSystem(r"C:\\Users\\Francesco\\Desktop\\Work_Units\\Sergio\\modelica_files\\myProcRes.mo","myProcRes")
    # print(dir(mod))
    # print(mod.getQuantities())

    # flattened_model = get_flattened_model()
    # print("This one is start:")
    # print(model)
    # print("This one is flattened:")
    # print(flattened_model)
    # base_model_definition = modparc.parse(model)
    # flattened_model_definition = modparc.parse(base_modelica)#flattened_model)
    # #print(flattened_model_definition)
    # print(get_all_components_type_name(flattened_model_definition))
    # print(get_all_components_type_name(base_model_definition))
    # #translate_flattened_model_to_owl(base_model_definition, flattened_model_definition)