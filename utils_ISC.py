import warnings
import sys
import os
import nibabel as nib
import numpy as np
import pandas as pd
from nilearn.input_data import NiftiLabelsMasker
from nilearn.image import load_img, math_img
import scipy.io

from sklearn.preprocessing import StandardScaler

if not sys.warnoptions:
    warnings.simplefilter("ignore")

base_path = '/u/project/rbilder/RDoC'
#base_path = '/Users/catherinewalsh/Documents/Code/RDoC_for_GitHub/data/MVPA/'
TR = 1.5

def load_yeo():
    data_path = base_path + '/Catherine/walsh_scripts/'
    #data_path = base_path
    mask_path = data_path + "Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii"
    labels_path = data_path + "Schaefer2018_400Parcels_7Networks_order.txt"
    atlas_yeo = nib.load(mask_path)
    labels_yeo = pd.read_csv(labels_path, sep="\t", header=None)
    labels_yeo = labels_yeo[1]
    return atlas_yeo, labels_yeo

def load_masked_DFR_data(sub, run, mask):

    # helper to load in a single run of DFR data and mask it
    nifti_masker = NiftiLabelsMasker(labels_img=mask)

    data_path = base_path + '/subjects/ID' + sub + '/analysis/fMRI/SPM'

    # Load MRI file (in Nifti format) of one localizer run
    DFR_in = os.path.join(data_path, "swrDFR_run%d.nii" % run)
    #DFR_in = os.path.join(base_path, "swrDFR_%s_run%d.nii" % (sub, run))

    DFR_data = nib.load(DFR_in)
    print("Loading data from %s" % DFR_in)
    DFR_masked_data = nifti_masker.fit_transform(DFR_data)
    DFR_masked_data = np.transpose(DFR_masked_data)
    return DFR_masked_data


def load_masked_rest(sub, mask):

    # helper to load in a single run of DFR data and mask it
    nifti_masker = NiftiLabelsMasker(labels_img=mask)
    data_path = base_path + '/subjects/ID' + sub + '/analysis/restfMRI/swrRestingState.nii'

    rest_in = os.path.join(data_path)
    rest_data = nib.load(rest_in)
    print("Loading rest from %s" % rest_in)

    rest_masked = nifti_masker.fit_transform(rest_data)
    return rest_masked


def load_all_masked_DFR_runs(sub, mask, num_runs):

    # returns concatenated list of all runs of the DFR task for a given subject
    masked_data_all = np.array([])
    for run in range(1, num_runs+1):
        temp_data = load_masked_DFR_data(sub, run, mask)
        if run == 1:
            masked_data_all = temp_data
        else:
            masked_data_all = np.hstack((masked_data_all, temp_data))
    masked_data_all = np.transpose(masked_data_all)
    return masked_data_all


def load_DFR_stim_labels(sub):

    #data_path = base_path+'/subjects/ID'+sub+'/analysis/fMRI/SPM'
    data_path = base_path
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
    return trial_data


def select_yeo_regions(data, labels):
    concat_list = (data[:, range(31)], data[:, range(68, 113)], data[:, range(126, 230)], data[:, range(270, 318)],
                   data[:, range(331, 400)])
    selected_regions = np.concatenate(concat_list, axis=1)
    selected_labels = labels[0:31]
    selected_labels = selected_labels.append(
        [labels[68:113], labels[126:230], labels[270:318], labels[331:400]]).reset_index(drop=True)
    return selected_regions, selected_labels

def convert_sec_to_TR(labels):
    converted_TR = np.copy(labels)

    # Cycle through each element in a run
    for i in range(64):
        # What is the time stamp
        time = int(labels[0,i])

        # What TR does this timepoint refer to?
        TR_idx = int(time / TR)
        converted_TR[0, i] = TR_idx
    return converted_TR


def reshape_DFR_into_trials(data, TR_labels):
    # reshape long list of 884 TRs into a new array of trials 14 TRs long
    TR_labels = convert_sec_to_TR(TR_labels)
    trial_data_reshaped = np.zeros((64, 14, data.shape[1]))

    for trial in range(0, 64):
        TR_idx = int(TR_labels[0, trial])
        temp_data = data[range(TR_idx, TR_idx + 14), :]
        trial_data_reshaped[trial, :, :] = temp_data

    return trial_data_reshaped


def create_trial_type_averages(reshaped_data, labels):
    data_in_trials = reshape_DFR_into_trials(reshaped_data, labels)

    # split a list of trials into averages by condition (high/low load, correct/incorrect)
    average_trials = np.zeros((4, 14, reshaped_data.shape[1]))
    cond_count = 0
    order = ['low correct', 'low incorrect', 'high correct', 'high incorrect']
    scaler = StandardScaler()
    for pair in ((1, 1), (0, 1), (1, 3), (0, 3)):

        trial_IDs = labels[:, ((labels[1, :] == pair[0]) & (labels[2, :] == pair[1]))]
        trial_IDs = trial_IDs[3, :].astype(int) - 1

        trials = data_in_trials[trial_IDs, :, :]

        average = np.mean(trials, axis=0)
        average_trials[cond_count, :, :] = average
        cond_count += 1

    return average_trials, order


def make_bilat_HPC(sub):
    #data_path = base_path + '/scripts/fmri/BetaSeries/individual_masks/'
    data_path = base_path
    l_file_name = "mask_LeftHPC_ID"+sub+".nii"
    r_file_name = "mask_RightHPC_ID"+sub+".nii"
    l_file_in = os.path.join(data_path, l_file_name)
    r_file_in = os.path.join(data_path, r_file_name)

    L_mask_img = load_img(l_file_in)
    L_mask = math_img('img > 0', img=L_mask_img)

    R_mask_img = load_img(r_file_in)
    R_mask = math_img('img > 0', img=R_mask_img)

    bilat_mask = math_img('img1 + img2', img1=R_mask, img2=L_mask)

    return bilat_mask