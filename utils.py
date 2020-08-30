import warnings
import sys
if not sys.warnoptions:
    warnings.simplefilter("ignore")
import os
import nibabel as nib
import numpy as np
from nilearn.input_data import NiftiMasker
from nilearn.image import load_img, math_img
import scipy.io

from sklearn.preprocessing import StandardScaler

# define constants
base_path = '/u/project/rbilder/RDoC'
#base_path = '/Users/catherinewalsh/Documents/Code/RDoC_for_GitHub/data/MVPA'
TR = 1.5
category_labels = {"Face": 1, "Object": 2, "Scramble": 3}
HRF_lag = 4.5
block_dur = 18
block_dur_TR = block_dur/TR
TR_per_run_loc = int(block_dur_TR * 18)+4
cue_dur = 2.5
delay_dur = 7.5
probe_dur = 7.5
trial_dur = cue_dur + delay_dur + probe_dur
trial_dur_TR = trial_dur/TR
TR_per_run_DFR = 884
DFR_measure_labels = ['trial_onsets_seconds', 'accuracy', 'load', 'trial_number']
DFR_average_order = ['low correct', 'low incorrect', 'high correct', 'high incorrect']


def load_loc_stim_labels(sub):

    # sub must be a string
    data_path = base_path+'/subjects/ID'+sub+'/analysis/fMRI/SPM'
    #data_path = base_path
    in_file = os.path.join(data_path, 'FFA_onsets_ID%s.mat' % sub)

    stim_data = scipy.io.loadmat(in_file)
    stim_data = np.array(stim_data['FFA_res'])

    event_times = np.transpose(np.concatenate((stim_data[0][0][0], stim_data[0][0][1], stim_data[0][0][2])))
    event_labels = np.transpose(np.concatenate((np.full((6, 1), 1), np.full((6, 1), 2), np.full((6, 1), 3))))
    event_block_label = np.transpose(np.concatenate(([1, 2, 3, 4, 5, 6], [1, 2, 3, 4, 5, 6], [1, 2, 3, 4, 5, 6])))

    sort_index = np.argsort(event_times[0])
    stim_labels = np.stack((np.sort(event_times[0]), event_labels[0][sort_index], event_block_label[sort_index]))
    return stim_labels


def load_DFR_stim_labels(sub):

    data_path = base_path+'/subjects/ID'+sub+'/analysis/fMRI/SPM'
    #data_path = base_path
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


def time2TR(stim_labels,TR_per_run):

    # stim labels should have a shape = (measures, events)
    # returns labels in units of TRs, expanded out so seeing all TRs (before only had onsets of blocks/trials)

    # Preset variables
    measures, events = stim_labels.shape

    # Preset the array with zeros
    labels = np.zeros((TR_per_run, measures-1))

    # Cycle through each element in a run
    for i in range(events):
        # What is the time stamp
        time = int(stim_labels[0, i])

        # What TR does this timepoint refer to?
        TR_idx = int(time / TR)

        # Add the condition label to this timepoint
        for measure in range(measures-1):
            labels[range(TR_idx, TR_idx + int(block_dur_TR)), measure] = stim_labels[measure+1, i]

    return labels


def shift_timing(label_TR, TR_shift_size):

    # shift TRs by a given amount, for example, hemodynamic delay
    # returns list of shifted labels with same dimensions as input

    # Create a short vector of extra zeros
    zero_shift = np.zeros((TR_shift_size, label_TR.shape[1]))

    # Zero pad the column from the top
    label_TR_shifted = np.vstack((zero_shift, label_TR))

    # Don't include the last rows that have been shifted out of the time line
    label_TR_shifted = label_TR_shifted[0:label_TR.shape[0], :]

    return label_TR_shifted


def mask_data(data, mask):

    # mask an fMRI image
    nifti_masker = NiftiMasker(mask_img=mask)
    masked_data = nifti_masker.fit_transform(data);
    masked_data = np.transpose(masked_data)
    return masked_data


def make_bilat_HPC(sub):
    data_path = base_path + '/scripts/fmri/BetaSeries/individual_masks/'
    #data_path = base_path
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


def load_masked_loc(sub, mask):

    # for Hoffman, smoothed data
    # data_path = base_path + '/subjects/ID' + sub + '/analysis/fMRI/SPM'
    # file_in = os.path.join(data_path, "swrLocalizerFFA.nii")

    # for Hoffman, unsmoothed data
    data_path = base_path + '/subjects/ID' + sub + '/analysis/temp'
    file_in = os.path.join(data_path, "wrLocalizerFFA.nii")

    # local data
    #file_in = os.path.join(base_path,"swrLocalizerFFA_%s.nii" % sub)
    file_data = nib.load(file_in)
    print("Loaded EPI for subject %s" % sub)

    masked_data = mask_data(file_data, mask)
    print("Masked EPI for subject %s" % sub)
    # there's 9s of fixation data at the the end that we don't care about - remove it
    masked_data = masked_data[:, range(0, 220)]
    return masked_data


def load_masked_DFR_data(sub, run, mask):

    # helper to load in a single run of DFR data and mask it
    nifti_masker = NiftiMasker(mask_img=mask)
    # Load MRI file (in Nifti format) of one localizer run

    # Hoffman, smoothed data
    # data_path = base_path + '/subjects/ID' + sub + '/analysis/fMRI/SPM'
    # DFR_in = os.path.join(data_path, "swrDFR_run%d.nii" % run)

    # Hoffman, unsmoothed data
    data_path = base_path + '/subjects/ID' + sub + '/analysis/temp'
    DFR_in = os.path.join(data_path, "wrDFR_run%d.nii" % run)

    # local data
    #DFR_in = os.path.join(base_path, "swrDFR_%s_run%d.nii" % (sub, run))

    DFR_data = nib.load(DFR_in)
    print("Loading data from %s" % DFR_in)
    DFR_masked_data = nifti_masker.fit_transform(DFR_data);
    DFR_masked_data = np.transpose(DFR_masked_data)
    return DFR_masked_data


def load_all_masked_DFR_runs(sub, mask, num_runs):

    # returns concatenated list of all runs of the DFR task for a given subject
    masked_data_all = np.array([])
    for run in range(1, num_runs+1):
        temp_data = load_masked_DFR_data(sub, run, mask)
        if run == 1:
            masked_data_all = temp_data
        else:
            masked_data_all = np.hstack((masked_data_all, temp_data))
    return masked_data_all


def reshape_data(label_TR_shifted, masked_data_all, zero_trial_num):

    # Extract bold data for non-zero labels
    label_index = np.nonzero(label_TR_shifted[:,zero_trial_num])
    label_index = np.squeeze(label_index)
    # Pull out the indexes
    indexed_data = np.transpose(masked_data_all[:,label_index])
    nonzero_labels = label_TR_shifted[label_index]
    return indexed_data, nonzero_labels


def find_top_voxels(sub, spm_img, mask, num_vox):

    # do feature selection: take to voxels from a given contrast map
    data_path = base_path + '/subjects/ID' + sub + '/analysis/fMRI/SPM/DFR_Art_Model2'
    #data_path = base_path
    cont_in = os.path.join(data_path, spm_img)
    contrast_data = nib.load(cont_in)

    # select out mask from contrast data
    nifti_masker = NiftiMasker(mask_img=mask)
    contrast_masked = nifti_masker.fit_transform(contrast_data)
    contrast_masked = np.transpose(contrast_masked[0])

    top_vox = np.argsort(contrast_masked)[::-1][0:num_vox]
    return top_vox

def convert_sec_to_TR(labels):
    converted_TR = np.copy(labels)

    # Cycle through each element in a run
    for i in range(64):
        # What is the time stamp
        time = int(labels[0,i])

        # What TR does this timepoint refer to?
        TR_idx = int(time / TR)
        converted_TR[0,i] = TR_idx
    return converted_TR


def reshape_DFR_into_trials(data, TR_labels):
    # reshape long list of 884 TRs into a new array of trials 14 TRs long
    TR_labels = convert_sec_to_TR(TR_labels)
    trial_data_reshaped = np.zeros((64, 14, data.shape[0]))

    for trial in range(0, 64):
        TR_idx = int(TR_labels[0, trial])
        temp_data = data[:, range(TR_idx, TR_idx + 14)]
        trial_data_reshaped[trial, :, :] = np.transpose(temp_data)

    return trial_data_reshaped


def create_trial_type_averages(reshaped_data, labels, normalize_in_trial=False):
    data_in_trials = reshape_DFR_into_trials(reshaped_data, labels)

    # split a list of trials into averages by condition (high/low load, correct/incorrect)
    average_trials = np.zeros((4, 14, reshaped_data.shape[0]))
    cond_count = 0
    order = ['low correct', 'low incorrect', 'high correct', 'high incorrect']
    scaler = StandardScaler()
    for pair in ((1, 1), (0, 1), (1, 3), (0, 3)):

        trial_IDs = labels[:, ((labels[1, :] == pair[0]) & (labels[2, :] == pair[1]))]
        trial_IDs = trial_IDs[3, :].astype(int) - 1

        trials = data_in_trials[trial_IDs, :, :]

        if normalize_in_trial:
            for trial in range(trials.shape[0]):
                trials[trial, :, :] = scaler.fit_transform(trials[trial, :, :])

        average = np.mean(trials, axis=0)
        average_trials[cond_count, :, :] = average
        cond_count += 1

    return average_trials, order

