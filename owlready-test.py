
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

fluffy = next(individuals)

p < fluffy.weigth
p < fluffy.loves
p < fluffy.name
p < fluffy.is_a
p < type(fluffy)
pp < fluffy
p<list(onto.properties())






