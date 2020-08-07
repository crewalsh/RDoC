import pickle
import pandas as pd
import scipy.stats
import numpy as np
from scipy.io import savemat

f = open('Yeo_DFR_rest.pckl', 'rb')
[DFR_all, rest_all] = pickle.load(f)
f.close()

subj_list = pd.read_csv('fMRI_demographics.csv')

DFR_corr = np.zeros((400, 400, 170))
rest_corr = np.zeros((400, 400, 170))

DFR_corr[:, :, :] = np.nan
rest_corr[:, :, :] = np.nan

FPCN_nodes = np.array(range(126, 148))
FPCN_nodes = np.append(FPCN_nodes, np.array(range(331, 361)))

for j, sub in enumerate(subj_list['PTID']):
    sub = str(sub)

    for region1 in range(400):
        for region2 in range(400):
            DFR_corr[region1, region2, j] = scipy.stats.pearsonr(DFR_all[:, region1, j], DFR_all[:, region2, j])[0]
            print("Finished DFR correlations")
            if sub not in ['1024', '1554']:
                rest_corr[region1, region2, j] = scipy.stats.pearsonr(rest_all[sub][:, region1],
                                                                      rest_all[sub][:, region2])[0]
                print("Finished rest correlations")

    print("finished subject %s" % sub)

FPCN_submatrix_DFR = DFR_corr[FPCN_nodes, :, :]
FPCN_submatrix_DFR = FPCN_submatrix_DFR[:, FPCN_nodes, :]

FPCN_submatrix_rest = rest_corr[FPCN_nodes, :, :]
FPCN_submatrix_rest = FPCN_submatrix_rest[:, FPCN_nodes, :]

print("selected out FPCN network")

f = open('task_rest_corr.pckl', 'wb')
pickle.dump([DFR_corr, rest_corr, FPCN_submatrix_DFR, FPCN_submatrix_rest], f)
f.close()

outdict= {"DFR_corr": DFR_corr, "rest_corr": rest_corr, "FPCN_submatrix_DFR": FPCN_submatrix_DFR,
          "FPCN_submatrix_rest": FPCN_submatrix_rest}
savemat('task_rest_corr.mat', outdict)

print("saved files")
