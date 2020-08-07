import pickle
import numpy as np
from scipy.spatial.distance import squareform

f = open('data/ISC.pckl', 'rb')
#[isc_pairwise, isc_LOO, reduced_labels, high_TR_ISC_pairwise, high_TR_ISC_LOO, low_TR_ISC_pairwise, low_TR_ISC_LOO] = pickle.load(f)
[isc_pairwise, isc_LOO, high_correct_spatial_corr, low_correct_spatial_corr, reduced_labels] = pickle.load(f)
f.close()

np.savetxt('data/ISC/ISC_LOO_high_correct.csv', isc_LOO["high_correct"], fmt='%.2f', delimiter=",")
np.savetxt('data/ISC/ISC_LOO_low_correct.csv', isc_LOO["low_correct"], fmt='%.2f', delimiter=",")

isc_pairwise_reshaped = {}
for key in isc_pairwise.keys():
    temp = np.zeros((170,170,297))
    for i in range(297):
        temp[:,:,i] = squareform(isc_pairwise[key][:,i])
    isc_pairwise_reshaped[key] = temp

np.save('data/ISC/ISC_pairwise_high_correct.npy', isc_pairwise_reshaped["high_correct"])
np.save('data/ISC/ISC_pairwise_low_correct.npy', isc_pairwise_reshaped["low_correct"])

