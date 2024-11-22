
from owlready2 import *
import types
from pprint import pprint


class Print():
	def __init__(self, flag = False):
		self.flag = flag
	def __lt__(self, item):
		if isinstance(item, types.GeneratorType):
			print(list(item))
			return
		if self.flag:
			pprint(vars(item))
			return
		print(item)
p = Print()
pp = Print(True)


onto_path.append(r"C:\Users\Francesco\Desktop\Work_Units\Sergio")
onto = get_ontology(r"file://fluffy.owl").load()


individuals = onto.individuals()

#p < individuals
#p < onto.classes()

doggo = next(individuals)

p < doggo.weigth
p < doggo.loves
p < doggo.name
p < doggo.is_a
p < type(doggo)
pp < doggo
p<list(onto.properties())






