import pickle
import numpy as np

f = open('data/spatial_ISC.pckl', 'rb')
[iscs_pairwise_high, iscs_LOO_high, iscs_pairwise_low, iscs_LOO_low] = pickle.load(f)
f.close()