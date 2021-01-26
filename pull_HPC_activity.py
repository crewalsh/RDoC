import pickle
import numpy as np
import pandas as pd


from utils_ISC import load_all_masked_DFR_runs_spatial, make_bilat_HPC, load_DFR_stim_labels, \
    create_trial_type_averages, do_ISC_LOO, do_ISC_pairwise

subj_list = pd.read_csv('fMRI_demographics.csv')
#subj_list = pd.read_csv('data/fMRI_demographics.csv')

raw_data = {}
suj_count = 0

high_correct = np.zeros((14,4000, 170))
low_correct = np.zeros((14, 4000, 170))
high_incorrect = np.zeros((14, 4000, 170))
low_incorrect = np.zeros((14, 4000, 170))

high_correct.fill(np.nan)
high_incorrect.fill(np.nan)
low_correct.fill(np.nan)
low_incorrect.fill(np.nan)

for sub in subj_list['PTID']:
    sub = str(sub)
    if sub not in ['1024']:
        mask = make_bilat_HPC(sub)

        data_dict = {}
        num_voxels = np.count_nonzero(mask.get_fdata())

        BOLD_data = load_all_masked_DFR_runs_spatial(sub, mask, 4)
        print("Trials loaded for sub %s" % (sub))

        DFR_onsets = np.squeeze(load_DFR_stim_labels(sub))
        DFR_average_trials, trial_type_order = create_trial_type_averages(BOLD_data, DFR_onsets)

        # add into single array: TR, voxels, subjs
        high_correct[:, 0:num_voxels, suj_count] = DFR_average_trials[2, :, :]
        low_correct[:, 0:num_voxels, suj_count] = DFR_average_trials[0, :, :]
        high_incorrect[:, 0:num_voxels, suj_count] = DFR_average_trials[3, :, :]
        low_incorrect[:, 0:num_voxels, suj_count] = DFR_average_trials[1, :, :]

        suj_count += 1
    else:
        high_correct[:, :, suj_count] = np.nan
        low_correct[:, :, suj_count] = np.nan
        high_incorrect[:, :, suj_count] = np.nan
        low_incorrect[:, :, suj_count] = np.nan
        suj_count += 1


# prep data to save
data_dict['high_correct'] = high_correct
data_dict['high_incorrect'] = high_incorrect
data_dict['low_correct'] = low_correct
data_dict['low_incorrect'] = low_incorrect

raw_data["HPC"] = data_dict

f = open('HPC_masked_DFR.pckl', 'wb')
pickle.dump([raw_data], f)
f.close()
print("saved raw data")

