import pickle
import nibabel as nib
import numpy as np
import pandas as pd

from utils_ISC import load_all_masked_DFR_runs_spatial, make_bilat_HPC, load_DFR_stim_labels, \
    create_trial_type_averages, do_ISC_LOO, do_ISC_pairwise

subj_list = pd.read_csv('fMRI_demographics.csv')
#subj_list = pd.read_csv('data/fMRI_demographics.csv')

maskfile_fusiform = "/u/project/rbilder/RDoC/Catherine/RSA/bilateral_fusiform_AAL.nii"
maskfile_DFR = "/u/project/rbilder/RDoC/Catherine/ROIs/Final_Full_Masks/I0C11delay_model3_thresh_4_389_binary.nii.gz"
#maskfile_fusiform = "data/MVPA/bilateral_fusiform_AAL.nii"
#maskfile_DFR = "data/MVPA/I0C11delay_model3_thresh_4_389_binary.nii"

mask_fusiform = nib.load(maskfile_fusiform)
mask_DFR = nib.load(maskfile_DFR)

all_ROI_masks = {"fusiform": mask_fusiform, "DFR": mask_DFR}

#ROI_names = [ "DFR", "fusiform", "HPC"]
ROI_names = [ "DFR", "fusiform"]

raw_data = {}

print("Loaded group masks")

# compute sISC for all ROIs

iscs_roi_high = {}
iscs_pairwise_high = {}
iscs_roi_low = {}
iscs_pairwise_low = {}

for j, roi_name in enumerate(ROI_names):
    max_voxels = np.count_nonzero(all_ROI_masks[roi_name].get_fdata())
    suj_count = 0
    high_correct = np.zeros((14, max_voxels, 170))
    low_correct = np.zeros((14, max_voxels, 170))
    high_incorrect = np.zeros((14, max_voxels, 170))
    low_incorrect = np.zeros((14, max_voxels, 170))

    high_correct.fill(np.nan)
    high_incorrect.fill(np.nan)
    low_correct.fill(np.nan)
    low_incorrect.fill(np.nan)

    data_dict = {}

    print(j, roi_name)
    # collect data from all subjects
    for sub in subj_list['PTID']:
    #for sub in ['1005']:
        sub = str(sub)
        if sub in ['1024']:
            if roi_name is not "HPC":
                mask = all_ROI_masks[roi_name]
                BOLD_data = load_all_masked_DFR_runs_spatial(sub, mask, 4)
                print("Trials loaded for sub %s, mask %s" % (sub, roi_name))

                DFR_onsets = np.squeeze(load_DFR_stim_labels(sub))
                DFR_average_trials, trial_type_order = create_trial_type_averages(BOLD_data, DFR_onsets)

                # add into single array: TR, regions, subjs
                high_correct[:, :, suj_count] = DFR_average_trials[2, :, :]
                low_correct[:, :, suj_count] = DFR_average_trials[0, :, :]
                high_incorrect[:, :, suj_count] = DFR_average_trials[3, :, :]
                low_incorrect[:, :, suj_count] = DFR_average_trials[1, :, :]
                suj_count += 1
        else:

            if roi_name == "HPC":
                mask = make_bilat_HPC(sub)
            else:
                mask = all_ROI_masks[roi_name]
            # load in DFR data, mask with appropriate mask
            BOLD_data = load_all_masked_DFR_runs_spatial(sub, mask, 4)
            print("Trials loaded for sub %s, mask %s" % (sub, roi_name))

            DFR_onsets = np.squeeze(load_DFR_stim_labels(sub))
            DFR_average_trials, trial_type_order = create_trial_type_averages(BOLD_data, DFR_onsets)

            # add into single array: TR, voxels, subjs
            high_correct[:, :, suj_count] = DFR_average_trials[2, :, :]
            low_correct[:, :, suj_count] = DFR_average_trials[0, :, :]
            high_incorrect[:, :, suj_count] = DFR_average_trials[3, :, :]
            low_incorrect[:, :, suj_count] = DFR_average_trials[1, :, :]

            suj_count += 1

    # prep data to save
    data_dict['high_correct'] = high_correct
    data_dict['high_incorrect'] = high_incorrect
    data_dict['low_correct'] = low_correct
    data_dict['low_incorrect'] = low_incorrect

    raw_data[roi_name] = data_dict

    # Compute isc for each ROI
    iscs_roi_high[roi_name] = do_ISC_LOO(np.transpose(high_correct, [1, 0, 2]))
    iscs_pairwise_high[roi_name] = do_ISC_pairwise(np.transpose(high_correct, [1, 0, 2]))

    print("finished high load ISCs for roi: %s" % roi_name)

    iscs_roi_low[roi_name] = do_ISC_LOO(np.transpose(low_correct, [1, 0, 2]))
    iscs_pairwise_low[roi_name] = do_ISC_pairwise(np.transpose(low_correct, [1, 0, 2]))

    print("finished low load ISCs for roi: %s" % roi_name)

f = open("spatial_ISC.pckl", 'wb')
pickle.dump([iscs_pairwise_high, iscs_roi_high, iscs_pairwise_low, iscs_roi_low], f)
f.close()
print("saved ISCs")

f = open('ROI_masked_DFR.pckl', 'wb')
pickle.dump([raw_data], f)
f.close()
print("saved raw data")

