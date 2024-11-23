import os, sys 
sys.path.append(os.path.dirname(os.path.realpath(__file__)))
sys.path.append(os.path.dirname(os.path.dirname(os.path.realpath(__file__))))
import sys, os
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.dirname(SCRIPT_DIR))
if __name__ == "__main__":
    print(0,__file__)
    print(1,os.path.realpath(__file__))
    print(2,os.path.dirname(os.path.realpath(__file__)))
    print(3,os.path.basename(os.path.realpath(__file__)))
    print(4,os.path.dirname(os.path.dirname(os.path.realpath(__file__))))