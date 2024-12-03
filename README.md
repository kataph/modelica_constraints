# Introduction

Generates a class-level ontology and a instance-level graph, based respectively on a modelica library and a user model extending that library. 

# Installation

Simply 
- clone the repository
- install the required dependencies. They are listed in the file requirements.txt. A possibility is to use the pip paclage manager with the command 
```
...\modelica_constraints> pip install -r requirements.txt
```
- execute the script main.py: see below 

# Usage

Example call:
```
...\modelica_constraints> python main.py LAS_Sim LAS_Sim.Examples.TwoAssembly_OneInspection_Station_Control -d Random
```
to get detailed help message for how to call the script: 
```
...\modelica_constraints> python main.py --help
```

After that, some files will be generated. In particular, an ontology containing an instance-level model with all the components. It can then be opened with Protegé and constraints can be checked by using the SHACL plugin and the supplied constraint library `modelica_constraints\constrants\LAS_Sim_current.shacl`. 

Due to the generation process, some axioms may be redundant. One can use e.g. the ROBOT tool to remove, say, redundant subClassOf axioms. For example:
```
java -jar robot.jar reduce --input ontologies/individual_plus_library.owl --output ontologies/individual_plus_library.owl
``` 
A copy of a release of the tool is present in `modelica_constraints\ontologies`, while the original repo is at [https://github.com/ontodev/robot]