import numpy as np
import pandas as pd
from nilearn.input_data import NiftiLabelsMasker
from scipy.stats import pearsonr
from scipy.spatial.distance import squareform
import nibabel as nib
from utils_isRSA_rest import load_yeo, create_indiv_masks

# load in atlas data
atlas_yeo, labels_yeo = load_yeo()
nifti_masker = NiftiLabelsMasker(labels_img=atlas_yeo)

reduced_yeo_idx = labels_yeo.str.contains('Cont|Default')
labels_yeo_reduced = labels_yeo[reduced_yeo_idx]

subj_list = pd.read_csv('fMRI_demographics.csv')

suj_count = 0

rest_corrs = np.zeros((169, 151, 151))
rest_pvals = np.zeros((169, 151, 151))

base_path = '/u/project/rbilder/RDoC'

for sub in subj_list['PTID']:
    if sub not in [1024, 1554]:
        rest_corr = np.zeros((151, 151))
        rest_pval = np.zeros((151, 151))

        # load data
        data_path = base_path + '/subjects/ID' + str(sub) + '/analysis/restfMRI/swrRestingState.nii'
        rest_data = nib.load(data_path)
        rest_yeo_masked = nifti_masker.fit_transform(rest_data)

        # select out only FPCN, DMN, etc
        rest_yeo_masked_reduced = rest_yeo_masked[:, reduced_yeo_idx]

        # load individual masks
        indiv_masked_data = create_indiv_masks(rest_data, sub)

        # compute correlations within yeo regions
        for yeo1 in range(143):
            for yeo2 in range(143):
                corr_info = pearsonr(rest_yeo_masked_reduced[:, yeo1], rest_yeo_masked_reduced[:, yeo2])
                rest_corr[yeo1, yeo2] = corr_info[0]
                rest_pval[yeo1, yeo2] = corr_info[1]

        # correlate yeo regions to individual regions
        for yeo in range(143):
            for idx, indiv in enumerate(indiv_masked_data):
                corr_info = pearsonr(rest_yeo_masked_reduced[:, yeo], indiv)
                rest_corr[yeo, idx+143] = corr_info[0]
                rest_pval[yeo, idx+143] = corr_info[1]
                rest_corr[idx+143, yeo] = corr_info[0]
                rest_pval[idx+143, yeo] = corr_info[1]

        # correlate within individual regions
        for idx1, indiv1 in enumerate(indiv_masked_data):
            for idx2, indiv2 in enumerate(indiv_masked_data):
                corr_info = pearsonr(indiv1, indiv2)
                rest_corr[idx+143, idx+143] = corr_info[0]
                rest_pval[idx+143, idx+143] = corr_info[1]

        # fill diagonal with 0s so can squareform later
        np.fill_diagonal(rest_corr, 0)
        # dump into shared matrix
        rest_corrs[suj_count, :, :] = rest_corr
        # save p-vals for sanity sake later
        rest_pvals[suj_count, :, :] = rest_pval
        suj_count = suj_count + 1
    print("finished sub:"+str(sub))

np.save(file="all_sub_RS_corr_reduced_yeo_with_indiv.npy", arr=rest_corrs)
np.save(file="all_sub_RS_pval_reduced_yeo_with_indiv.npy", arr=rest_pvals)

sub_rest_corr = np.zeros((169, 169))
sub_rest_pval = np.zeros((169, 169))

for sub1 in range(169):
    for sub2 in range(169):
        sub1_rest = squareform(rest_corrs[sub1, :, :])
        sub2_rest = squareform(rest_corrs[sub2, :, :])
        corr_temp = pearsonr(sub1_rest, sub2_rest)
        sub_rest_corr[sub1, sub2] = corr_temp[0]
        sub_rest_pval[sub1, sub2] = corr_temp[1]

np.save(file="cross_sub_reduced_yeo_with_indiv_RS_corr.npy", arr=sub_rest_corr)
np.save(file="cross_sub_reduced_yeo_with_indiv_RS_pval.npy", arr=sub_rest_pval)


