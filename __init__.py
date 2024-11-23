import os, sys 
sys.path.append(os.path.dirname(os.path.realpath(__file__)))
if __name__ == "__main__":
    print(0,__file__)
    print(1,os.path.realpath(__file__))
    print(2,os.path.dirname(os.path.realpath(__file__)))