import pickle
import numpy as np
import pandas as pd
from brainiak.isc import isc

from utils_ISC import create_trial_type_averages

full_data = np.load('data/ISC/full_matlab_data.npy')
full_data = np.transpose(full_data, [2, 1, 0])
print("data loaded")

subj_list = pd.read_csv('data/fMRI_demographics.csv')

f = open('data/ISC/onsets.pckl', 'rb')
onsets = pickle.load(f)
f.close()

max_voxels = 4808

suj_count = 0

high_correct = np.zeros((14, max_voxels, 170))
low_correct = np.zeros((14, max_voxels, 170))
high_incorrect = np.zeros((14, max_voxels, 170))
low_incorrect = np.zeros((14, max_voxels, 170))

high_correct.fill(np.nan)
high_incorrect.fill(np.nan)
low_correct.fill(np.nan)
low_incorrect.fill(np.nan)

iscs_roi_high = {}
iscs_pairwise_high = {}
iscs_roi_low = {}
iscs_pairwise_low = {}

for sub in subj_list['PTID']:
    sub = str(sub)
    DFR_onsets = np.squeeze(onsets[sub])
    DFR_average_trials, trial_type_order = create_trial_type_averages(full_data[:, :, suj_count], DFR_onsets)

    # add into single array: TR, regions, subjs
    high_correct[:, :, suj_count] = DFR_average_trials[2, :, :]
    low_correct[:, :, suj_count] = DFR_average_trials[0, :, :]
    high_incorrect[:, :, suj_count] = DFR_average_trials[3, :, :]
    low_incorrect[:, :, suj_count] = DFR_average_trials[1, :, :]
    suj_count += 1

print("finished averaging trials")

# Compute isc for each ROI
iscs_roi_high["matlab"] = isc(np.transpose(high_correct, [1, 0, 2]), tolerate_nans=True)
iscs_pairwise_high["matlab"] = isc(np.transpose(high_correct, [1, 0, 2]), pairwise=True)

print("finished high load ISCs")

iscs_roi_low["matlab"] = isc(np.transpose(low_correct, [1, 0, 2]))
iscs_pairwise_low["matlab"] = isc(np.transpose(low_correct, [1, 0, 2]), pairwise=True)

print("finished low load ISCs")

f = open("spatial_ISC_matlab_test.pckl", 'wb')
pickle.dump([iscs_pairwise_high, iscs_roi_high, iscs_pairwise_low, iscs_roi_low], f)
f.close()
print("saved ISCs")
