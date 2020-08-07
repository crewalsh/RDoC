import pickle
import numpy as np
import pandas as pd
from brainiak.isc import isc

from utils_ISC import load_yeo, load_all_masked_DFR_runs, select_yeo_regions, load_DFR_stim_labels, \
    create_trial_type_averages

high_correct = np.zeros((14, 297, 170))
low_correct = np.zeros((14, 297, 170))
high_incorrect = np.zeros((14, 297, 170))
low_incorrect = np.zeros((14, 297, 170))

subj_list = pd.read_csv('fMRI_demographics.csv')
#subj_list = pd.read_csv('data/fMRI_demographics.csv')

suj_count = 0

# load in atlas data
atlas_yeo, labels_yeo = load_yeo()

for sub in subj_list['PTID']:
#for sub in ['1005']:

    sub = str(sub)
    # load in DFR data, mask with atlas
    BOLD_data = load_all_masked_DFR_runs(sub, atlas_yeo, 4)

    # select out only Yeo regions we care about
    reduced_data, reduced_labels = select_yeo_regions(BOLD_data, labels_yeo)

    # average over trials

    DFR_onsets = np.squeeze(load_DFR_stim_labels(sub))
    DFR_average_trials, trial_type_order = create_trial_type_averages(reduced_data, DFR_onsets)

    # add into single array: TR, regions, subjs
    high_correct[:, :, suj_count] = DFR_average_trials[2, :, :]
    low_correct[:, :, suj_count] = DFR_average_trials[0, :, :]
    high_incorrect[:, :, suj_count] = DFR_average_trials[3, :, :]
    low_incorrect[:, :, suj_count] = DFR_average_trials[1, :, :]

    suj_count += 1

print("All subjects loaded")

f = open("Yeo_masked_DFR.pckl", "wb")
pickle.dump([high_correct, low_correct, high_incorrect, low_incorrect, reduced_labels], f)
f.close()
print("Raw data saved")

isc_pairwise = {}
isc_LOO = {}

isc_pairwise["high_correct"] = isc(high_correct, pairwise=True)
isc_pairwise["low_correct"] = isc(low_correct, pairwise=True)

print("Finished pairwise ISC")

isc_LOO["high_correct"] = isc(high_correct, pairwise=False)
isc_LOO["low_correct"] = isc(low_correct, pairwise=False)

print("finished leave one out ISC")

f = open('ISC.pckl', 'wb')
pickle.dump([isc_pairwise, isc_LOO, reduced_labels], f)
f.close()

