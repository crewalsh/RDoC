import pickle
import numpy as np
import pandas as pd

from utils_ISC import load_yeo, load_all_masked_DFR_runs, load_masked_rest

subj_list = pd.read_csv('fMRI_demographics.csv')

suj_count = 0

# load in atlas data
atlas_yeo, labels_yeo = load_yeo()

DFR_all = np.zeros((884, 400, 170))
rest_all = {}

for j, sub in enumerate(subj_list['PTID']):
#for sub in ['1005']:

    sub = str(sub)
    # load in DFR data, mask with atlas
    if not sub in ['1024', '1554']:
        rest_data = load_masked_rest(sub, atlas_yeo)
        rest_all[sub] = rest_data

    BOLD_data = load_all_masked_DFR_runs(sub, atlas_yeo, 4)

    # select out only Yeo regions we care about

    DFR_all[:, :, j] = BOLD_data

f = open('yeo_DFR_rest.pckl', 'wb')
pickle.dump([DFR_all, rest_all], f)
f.close()
