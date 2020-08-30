import pickle
import numpy as np
import pandas as pd
import nibabel as nib

# machine learning imports
from sklearn.model_selection import GridSearchCV, PredefinedSplit
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler

# functions I wrote
from utils import load_loc_stim_labels, load_DFR_stim_labels, time2TR, shift_timing, load_masked_loc, \
    load_all_masked_DFR_runs, reshape_data, find_top_voxels, create_trial_type_averages, make_bilat_HPC
from utils import base_path, DFR_measure_labels, DFR_average_order, TR_per_run_loc, TR_per_run_DFR, TR, HRF_lag, \
    category_labels

subj_list = pd.read_csv('fMRI_demographics.csv')
#subj_list = pd.read_csv('data/fMRI_demographics.csv')

all_suj_low_corr = np.zeros((170, 14))
all_suj_low_incorr = np.zeros((170, 14))
all_suj_high_corr = np.zeros((170, 14))
all_suj_high_incorr = np.zeros((170, 14))

all_suj_indiv_trial_preds = np.zeros((170, 4, 14))
all_suj_indiv_trial_probs = np.zeros((170, 4, 14))

all_suj_clf_score = np.zeros((170, 6))
all_suj_C_best = np.zeros((170, 6))

suj_count = 0

# load in mask - this is not unique to subjects, so we only have to do it once
#maskfile = "/u/project/rbilder/RDoC/Catherine/RSA/bilateral_fusiform_AAL.nii"
maskfile = "/u/project/rbilder/RDoC/Catherine/ROIs/Final_Full_Masks/I0C11delay_model3_thresh_4_389_binary.nii.gz"
#maskfile = "data/MVPA/bilateral_fusiform_AAL.nii"
#maskfile = "data/MVPA/I0C11delay_model3_thresh_4_389_binary.nii"

mask = nib.load(maskfile)
print("Loaded mask")

for sub in subj_list['PTID']:
#for sub in ['1005']:
    sub = str(sub)
    #if sub not in ['1024']:

    # load in mask for individual subject
    #mask = make_bilat_HPC(sub)
    #print("Loaded mask for sub %s" % sub)
    # load in onsets

    fusiform_onsets = load_loc_stim_labels(sub)
    fusiform_TR_onsets = time2TR(fusiform_onsets, TR_per_run_loc)

    DFR_onsets = np.squeeze(load_DFR_stim_labels(sub))
    DFR_TR_onsets = time2TR(DFR_onsets, TR_per_run_DFR)

    # shift for HRF

    shift_size = int(HRF_lag / TR)

    fusiform_TR_onsets_shifted = shift_timing(fusiform_TR_onsets, shift_size)
    DFR_TR_onsets_shifted = shift_timing(DFR_TR_onsets, shift_size)

    # load in fMRI data

    masked_fusiform_data = load_masked_loc(sub, mask)
    masked_DFR_data = load_all_masked_DFR_runs(sub, mask, 4)

    # Check dimensionality

    print('subject %s: fusiform:  voxel by TR matrix - shape: ' % sub, masked_fusiform_data.shape)
    print('subject %s: fusiform: label list - shape: ' % sub, fusiform_TR_onsets_shifted.shape)
    print()
    print('subject %s: DFR:  voxel by TR matrix - shape: ' % sub, masked_DFR_data.shape)
    print('subject %s: DFR: label list - shape: ' % sub, DFR_TR_onsets_shifted.shape)

    # feature select based on top voxels from Faces vs Objects contrast
    spm_img_file = "spmT_0004.img"
    #spm_img_file = "1005_FFA_FvO.img"
    top_voxels = find_top_voxels(sub, spm_img_file, mask, 100)

    # extract BOLD from non-zero labels (only really matters for the fusiform)
    roi_masked_data = masked_fusiform_data[top_voxels]
    fusiform_data_masked_reduced_nonzero, fusiform_TR_onsets_shifted_nonzero = reshape_data(fusiform_TR_onsets_shifted,
                                                                                            roi_masked_data, 0)

    DFR_data_masked_reduced = masked_DFR_data[top_voxels]

    # create average trial types for DFR
    DFR_average_trials = create_trial_type_averages(DFR_data_masked_reduced, DFR_onsets)

    # run classifier
    run_ids = fusiform_TR_onsets_shifted_nonzero[:, 1] - 1

    # set up collector arrays
    sp = PredefinedSplit(run_ids)
    clf_score = np.array([])
    C_best = []
    high_corr_score = np.array([])
    high_incorr_score = np.array([])
    low_corr_score = np.array([])
    low_incorr_score = np.array([])
    DFR_predictions_trials = np.zeros((6, 4, 14))
    DFR_probabilities_trials = np.zeros((6, 4, 14))
    pred_count = 0

    scaler = StandardScaler()

    # Outer loop:
    # Split training (including validation) and testing set
    for train, test in sp.split():
        # Pull out the sample data
        X_train, X_test = fusiform_data_masked_reduced_nonzero[train], fusiform_data_masked_reduced_nonzero[test]
        y_train, y_test = fusiform_TR_onsets_shifted_nonzero[train, 0], fusiform_TR_onsets_shifted_nonzero[test, 0]
        X_train_normalized, X_test_normalized = scaler.fit_transform(X_train), scaler.fit_transform(X_test)
        train_run_ids = run_ids[train]

        # Inner loop (implicit, in GridSearchCV):
        # Split training and validation set
        sp_train = PredefinedSplit(train_run_ids)

        # Search over different cost parameters
        parameters = {'C': [0.01, 0.1, 1, 10]}
        inner_clf = GridSearchCV(
            SVC(kernel='linear'),
            parameters,
            cv=sp_train,
            return_train_score=True)
        inner_clf.fit(X_train_normalized, y_train)

        # Find the best hyperparameter
        C_best_i = inner_clf.best_params_['C']
        C_best.append(C_best_i)

        # Train the classifier with the best hyperparameter using training and validation set
        classifier = SVC(kernel="linear", C=C_best_i)
        clf = classifier.fit(X_train_normalized, y_train)

        # Test the classifier
        score = clf.score(X_test_normalized, y_test)
        clf_score = np.hstack((clf_score, score))

        # Apply classifier to individual DFR trials
        DFR_normalized = scaler.fit_transform(np.transpose(DFR_data_masked_reduced))
        DFR_predictions = clf.predict(DFR_normalized)
        DFR_predictions = np.reshape(DFR_predictions, (1, 884))
        DFR_probabilities = np.copy(DFR_predictions)
        DFR_probabilities[DFR_predictions != 1] = 0

        DFR_predictions_trials_i = create_trial_type_averages(DFR_predictions, DFR_onsets)
        DFR_predictions_trials[pred_count, :, :] = np.squeeze(DFR_predictions_trials_i[0])

        DFR_probabilities_trials_i = create_trial_type_averages(DFR_probabilities, DFR_onsets)
        DFR_probabilities_trials[pred_count, :, :] = np.squeeze(DFR_probabilities_trials_i[0])

        pred_count += 1

        # Apply classifier to average correct high load trial
        correct_high_preds = clf.predict(scaler.fit_transform(DFR_average_trials[0][2, :, :]))
        correct_high_preds_prob_i = np.copy(correct_high_preds)
        correct_high_preds_prob_i[correct_high_preds != 1] = 0
        if high_corr_score.size == 0:
            high_corr_score = correct_high_preds_prob_i
        else:
            high_corr_score = np.vstack((high_corr_score, correct_high_preds_prob_i))

        # Apply classifier to average correct low load trial
        if not np.isnan(scaler.fit_transform(DFR_average_trials[0][0, :, :])).all():
            correct_low_preds = clf.predict(scaler.fit_transform(DFR_average_trials[0][0, :, :]))
            correct_low_preds_prob_i = np.copy(correct_low_preds)
            correct_low_preds_prob_i[correct_low_preds != 1] = 0
            if low_corr_score.size == 0:
                low_corr_score = correct_low_preds_prob_i
            else:
                low_corr_score = np.vstack((low_corr_score, correct_low_preds_prob_i))

        # Apply classifier to average incorrect high load trial
        incorrect_high_preds = clf.predict(scaler.fit_transform(DFR_average_trials[0][3, :, :]))
        incorrect_high_preds_prob_i = np.copy(incorrect_high_preds)
        incorrect_high_preds_prob_i[incorrect_high_preds != 1] = 0
        if high_incorr_score.size == 0:
            high_incorr_score = incorrect_high_preds_prob_i
        else:
            high_incorr_score = np.vstack((high_incorr_score, incorrect_high_preds_prob_i))

        # Apply classifier to average incorrect low load trial
        if not np.isnan(scaler.fit_transform(DFR_average_trials[0][1, :, :])).all():
            incorrect_low_preds = clf.predict(scaler.fit_transform(DFR_average_trials[0][1, :, :]))
            incorrect_low_preds_prob_i = np.copy(incorrect_low_preds)
            incorrect_low_preds_prob_i[incorrect_low_preds != 0] = 0
            if low_incorr_score.size == 0:
                low_incorr_score = incorrect_low_preds_prob_i
            else:
                low_incorr_score = np.vstack((low_incorr_score, incorrect_low_preds_prob_i))

    all_suj_clf_score[suj_count, :] = clf_score
    all_suj_C_best[suj_count, :] = C_best

    # calculate average over CVs for individual trials
    all_suj_indiv_trial_preds[suj_count, :, :] = np.nanmean(DFR_predictions_trials, axis=0)
    all_suj_indiv_trial_probs[suj_count, :, :] = np.nanmean(DFR_probabilities_trials, axis=0)

    # calculate average over CVs for templates
    if not np.isnan(DFR_average_trials[0][0, :, :]).all():
        all_suj_low_corr[suj_count, :] = np.nanmean(low_corr_score, axis=0)
    else:
        all_suj_low_corr[suj_count, :] = np.nan
    if not np.isnan(DFR_average_trials[0][1, :, :]).all():
        all_suj_low_incorr[suj_count, :] = np.nanmean(low_incorr_score, axis=0)
    else:
        all_suj_low_incorr[suj_count, :] = np.nan
    all_suj_high_corr[suj_count, :] = np.nanmean(high_corr_score, axis=0)
    all_suj_high_incorr[suj_count, :] = np.nanmean(high_incorr_score, axis=0)

    suj_count += 1
    print("Finished subject %s" % sub)
    print()
    # else:
    #     all_suj_clf_score[suj_count, :] = np.nan
    #     all_suj_C_best[suj_count, :] = np.nan
    #     all_suj_indiv_trial_preds[suj_count, :, :] = np.nan
    #     all_suj_indiv_trial_probs[suj_count, :, :] = np.nan
    #     all_suj_low_corr[suj_count, :] = np.nan
    #     all_suj_low_incorr[suj_count, :] = np.nan
    #     all_suj_high_corr[suj_count, :] = np.nan
    #     all_suj_high_incorr[suj_count, :] = np.nan
    #     suj_count += 1

print("Finished all subjects")
f = open('MVPA_data_DFR_unsmoothed.pckl', 'wb')
pickle.dump([all_suj_C_best, all_suj_clf_score, all_suj_high_corr, all_suj_high_incorr, all_suj_low_corr,
             all_suj_low_incorr, all_suj_indiv_trial_preds, all_suj_indiv_trial_probs, DFR_measure_labels,
             DFR_average_order, category_labels], f)
f.close()
print("File saved")

