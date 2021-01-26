import warnings
import sys
import nibabel as nib
import pandas as pd
from nilearn.input_data import NiftiMasker
from nilearn.image import math_img


if not sys.warnoptions:
    warnings.simplefilter("ignore")

base_path = '/u/project/rbilder/RDoC'
#base_path = '/Users/catherinewalsh/Documents/Code/RDoC_for_GitHub/data/MVPA/'
indiv_mask_dir = '/u/project/rbilder/RDoC/scripts/fmri/BetaSeries/individual_masks/'


def load_yeo():
    data_path = base_path + '/Catherine/walsh_scripts/'
    #data_path = base_path
    mask_path = data_path + "Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii"
    labels_path = data_path + "Schaefer2018_400Parcels_7Networks_order.txt"
    atlas_yeo = nib.load(mask_path)
    labels_yeo = pd.read_csv(labels_path, sep="\t", header=None)
    labels_yeo = labels_yeo[1]
    return atlas_yeo, labels_yeo


def mask_data(data, mask):
    nifti_masker = NiftiMasker(mask_img=mask)
    masked_data = nifti_masker.fit_transform(data)
    return masked_data


def create_indiv_masks(data, sub):
    indiv_mask_data = []
    indiv_masks_loc = ['mask_LeftHPC_Post_ID' + str(sub)+'.nii',
                   'mask_LeftHPC_Med_ID' + str(sub)+'.nii',
                   'mask_LeftHPC_Ant_ID' + str(sub)+'.nii',
                   'mask_RightHPC_Post_ID' + str(sub) + '.nii',
                   'mask_RightHPC_Med_ID' + str(sub) + '.nii',
                   'mask_RightHPC_Ant_ID' + str(sub) + '.nii',
                   'mask_L_FFA_ID' + str(sub) + '.nii',
                   'mask_R_FFA_ID' + str(sub) + '.nii']

    for mask in indiv_masks_loc:
        mask_path = indiv_mask_dir + mask
        temp_mask = nib.load(mask_path)
        # binarize HPC masks
        if 'HPC' in mask_path:
            temp_mask = math_img('img > 0', img=temp_mask)
        masked_data = mask_data(data, temp_mask)
        # need to average over all voxels to be able to correlate
        indiv_mask_data.append(masked_data.mean(axis=1))

    return indiv_mask_data