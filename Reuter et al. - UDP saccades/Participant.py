# import libraries 
import matplotlib.pyplot as plt 
plt.rcParams.update({'font.size': 16}) 
import numpy as np 
import savingfigR as sf 

class Participant: 

    # private properties 
    targets = np.deg2rad(np.linspace(0, 360, 30))
    r = 10 # radius (cm)
    # methods 
    
    def __init__(self): # constructor 
        self.plotTargets()

    def ang2xy(self):
        return np.array([[self.r * np.cos(self.targets)], [self.r * np.sin(self.targets)]])

    def plotTargets(self):
        plt.figure()
        xy = self.ang2xy()
        plt.scatter(xy[0,:], xy[1,:])
        plt.show()


# call object 
TEST = Participant()