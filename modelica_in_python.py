from buildingspy.simulate.OpenModelica import Simulator
s=Simulator("electrical-circuit-example", packagePath=r"C:\Users\Francesco\Desktop\Work_Units\Sergio")
s.addModelModifier('redeclare package MediumA = Buildings.Media.IdealGases.SimpleAir')

#s.addParameters({'PID.k': 1.0, 'valve.m_flow_nominal' : 0.1})
#s.addParameters({'PID.t': 10.0})
