import os
import scipy.io
import pandas as pd
import numpy as np
import pickle

subj_list = pd.read_csv('fMRI_demographics.csv')

base_path = '/u/project/rbilder/RDoC'
onset_dict = {}

for sub in subj_list['PTID']:
    sub = str(sub)
    data_path = base_path+'/subjects/ID'+sub+'/analysis/fMRI/SPM'
    in_file = os.path.join(data_path, 'DFR_onsets_ID%s.mat' % sub)

    stim_labels = scipy.io.loadmat(in_file)
    stim_labels = np.array(stim_labels['DFR_struct'])

    all_trial_onsets = np.array([])
    all_acc = np.array([])
    all_load = np.array([])
    trial_num = np.array([])
    for run in range(0, 4):

        temp_acc = stim_labels['acc'][0][0][0][run]
        temp_load = stim_labels['load'][0][0][0][run]
        temp_trial = stim_labels['trial'][0][0][0][run]
        run_onsets = stim_labels['cue_onset'][0][0][0][run]
        run_onsets = 221 * 1.5 * run + run_onsets
        if run == 0:
            all_trial_onsets = run_onsets
            all_acc = temp_acc
            all_load = temp_load
            trial_num = temp_trial
        else:
            all_trial_onsets = np.vstack((all_trial_onsets, run_onsets))
            all_acc = np.vstack((all_acc, temp_acc))
            all_load = np.vstack((all_load, temp_load))
            trial_num = np.vstack((trial_num, temp_trial))

    trial_data = np.stack((all_trial_onsets, all_acc, all_load, trial_num))

    onset_dict[sub] = trial_data

f = open("onsets.pckl", 'wb')
pickle.dump(onset_dict, f)
f.close()

f = open('data/ISC/onsets.pckl', 'rb')
onsets = pickle.load(f)
f.close()
