import pickle
import pandas as pd
import numpy as np
from scipy.io import savemat, loadmat

# load data

f = open('data/task_rest_corr.pckl', 'rb')
[DFR_corr, rest_corr, FPCN_submatrix_DFR, FPCN_submatrix_rest] = pickle.load(f)
f.close()

subj_list = pd.read_csv('data/fMRI_demographics.csv')
region_list = pd.read_table('data/Schaefer2018_400Parcels_7Networks_order.txt', header=None)

mat_data = loadmat('data/WSBM_output.mat')

# calculate average region to region correlation
avg_DFR_corr = np.mean(DFR_corr, axis=2)
avg_rest_corr = np.nanmean(rest_corr, axis=2)

# average over networks
vis_idx = region_list[region_list[1].str.contains("Vis")][0] - 1
som_mot_idx = region_list[region_list[1].str.contains("SomMot")][0] - 1
DAN_idx = region_list[region_list[1].str.contains("DorsAttn")][0] - 1
VAN_idx = region_list[region_list[1].str.contains("SalVentAttn")][0] - 1
limbic_idx = region_list[region_list[1].str.contains("Limbic")][0] - 1
FPCN_idx = region_list[region_list[1].str.contains("Cont")][0] - 1
DMN_idx = region_list[region_list[1].str.contains("Default")][0] - 1

region_idx_list = [[vis_idx], [som_mot_idx], [DAN_idx], [VAN_idx], [limbic_idx], [FPCN_idx], [DMN_idx]]

region_corr_DFR = np.zeros((7, 7))
region_corr_DFR[:, :] = np.nan
region_corr_rest = np.zeros((7, 7))
region_corr_rest[:, :] = np.nan

for region1 in range(7):
    for region2 in range(7):
        temp_data = np.squeeze(avg_DFR_corr[region_idx_list[region1], :])
        temp_data = np.squeeze(temp_data[:, region_idx_list[region2]])

        region_corr_DFR[region1,region2] = np.mean(np.mean(temp_data))

        temp_data = np.squeeze(avg_rest_corr[region_idx_list[region1], :])
        temp_data = np.squeeze(temp_data[:, region_idx_list[region2]])

        region_corr_rest[region1,region2] = np.mean(np.mean(temp_data))
