import pickle
import numpy as np


f = open('data/MVPA/MVPA_data_HPC.pckl', 'rb')
[all_suj_C_best, all_suj_clf_score, all_suj_high_corr, all_suj_high_incorr, all_suj_low_corr,
             all_suj_low_incorr, all_suj_indiv_trial_preds, all_suj_indiv_trial_probs, DFR_measure_labels,
             DFR_average_order, category_labels, all_suj_acc]= pickle.load(f)

f.close()

np.savetxt('data/MVPA/csvs/best_C.csv', all_suj_C_best, fmt='%.2f', delimiter=",", header="cv_1, cv_2, cv_3, cv_4, cv_5, cv_6")
np.savetxt('data/MVPA/csvs/clf_acc.csv', all_suj_clf_score, fmt='%.4f', delimiter=",", header="cv_1, cv_2, cv_3, cv_4, cv_5, cv_6")
np.savetxt('data/MVPA/acc_')
np.savetxt('data/MVPA/csvs/all_suj_high_correct_avg.csv', all_suj_high_corr,  fmt='%.4f', delimiter=",")
np.savetxt('data/MVPA/csvs/all_suj_high_incorrect_avg.csv', all_suj_high_incorr,  fmt='%.4f', delimiter=",")
np.savetxt('data/MVPA/csvs/all_suj_low_correct_avg.csv', all_suj_low_corr,  fmt='%.4f', delimiter=",")
np.savetxt('data/MVPA/csvs/all_suj_low_incorrect_avg.csv', all_suj_low_incorr,  fmt='%.4f', delimiter=",")

np.savetxt('data/MVPA/csvs/all_suj_high_correct_indiv_trial_avg_probs.csv', all_suj_indiv_trial_probs[:,2,:],  fmt='%.4f', delimiter=",")
np.savetxt('data/MVPA/csvs/all_suj_high_incorrect_indiv_trial_avg_probs.csv', all_suj_indiv_trial_probs[:,3,:],  fmt='%.4f', delimiter=",")
np.savetxt('data/MVPA/csvs/all_suj_low_correct_indiv_trial_avg_probs.csv', all_suj_indiv_trial_probs[:,0,:],  fmt='%.4f', delimiter=",")
np.savetxt('data/MVPA/csvs/all_suj_low_incorrect_indiv_trial_avg_probs.csv', all_suj_indiv_trial_probs[:,1,:],  fmt='%.4f', delimiter=",")

np.savetxt('data/MVPA/csvs/all_suj_high_correct_indiv_trial_avg_preds.csv', all_suj_indiv_trial_preds[:,2,:],  fmt='%.4f', delimiter=",")
np.savetxt('data/MVPA/csvs/all_suj_high_incorrect_indiv_trial_avg_preds.csv', all_suj_indiv_trial_preds[:,3,:],  fmt='%.4f', delimiter=",")
np.savetxt('data/MVPA/csvs/all_suj_low_correct_indiv_trial_avg_preds.csv', all_suj_indiv_trial_preds[:,0,:],  fmt='%.4f', delimiter=",")
np.savetxt('data/MVPA/csvs/all_suj_low_incorrect_indiv_trial_avg_preds.csv', all_suj_indiv_trial_preds[:,1,:],  fmt='%.4f', delimiter=",")