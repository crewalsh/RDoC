import pickle
import numpy as np

basepath = "/Users/catherinewalsh/Documents/Code/RDoC_for_GitHub/data/"

# f = open(basepath + "ROI_masked_DFR.pckl", 'rb')
# raw_fus_DFR = pickle.load(f)
# f.close()

f = open(basepath + "HPC_masked_DFR.pckl")
raw_HPC = pickle.load(f)
f.close()

#raw_data = {**raw_fus_DFR, **raw_HPC}
raw_data = raw_HPC[0]

for ROI in raw_data.keys():
    LE_raw = raw_data[ROI]["high_correct"] - raw_data[ROI]['low_correct']
    LE = np.nanmean(LE_raw, axis=1)
    np.savetxt(basepath+ROI+"_LE_activity.csv", LE, delimiter=',')