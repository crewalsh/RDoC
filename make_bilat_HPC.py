import nibabel as nib
import nilearn.masking
from nilearn.image import load_img, math_img
from nilearn import plotting

L_mask_img = load_img("data/MVPA/mask_LeftHPC_ID1005.nii")
L_mask = math_img('img > 0', img=L_mask_img)

R_mask_img = load_img("data/MVPA/mask_RightHPC_ID1005.nii")
R_mask = math_img('img > 0', img=R_mask_img)

bilat_mask = math_img('img1 + img2', img1=R_mask, img2=L_mask)
