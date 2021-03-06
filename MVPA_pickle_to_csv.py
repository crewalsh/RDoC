import pandas as pd
import pickle

mask = "HPC"

basepath = "/Users/catherinewalsh/Documents/Code/RDoC_for_GitHub/data/MVPA/"+mask+"_unsmoothed/"
data_path = basepath+"MVPA_data_"+mask+"_unsmoothed.pckl"

f = open(data_path, 'rb')

[all_suj_C_best, all_suj_clf_score, all_suj_high_corr, all_suj_high_incorr, all_suj_low_corr,
             all_suj_low_incorr, all_suj_indiv_trial_preds, all_suj_indiv_trial_probs, DFR_measure_labels,
             DFR_average_order, category_labels, all_suj_acc] = pickle.load(f)

pd.DataFrame(all_suj_C_best).to_csv(basepath+"best_C.csv", index=False, header=None)
pd.DataFrame(all_suj_clf_score).to_csv(basepath+"clf_acc.csv", index=False, header=None)

pd.DataFrame(all_suj_high_corr).to_csv(basepath+"all_suj_high_correct_avg.csv", index=False, header=None)
pd.DataFrame(all_suj_high_incorr).to_csv(basepath+"all_suj_high_incorrect_avg.csv", index=False, header=None)
pd.DataFrame(all_suj_low_corr).to_csv(basepath+"all_suj_low_correct_avg.csv", index=False, header=None)
pd.DataFrame(all_suj_low_incorr).to_csv(basepath+"all_suj_low_incorrect_avg.csv", index=False, header=None)
pd.DataFrame(all_suj_acc).to_csv(basepath+"all_suj_acc.csv", index=False, header=None)


pd.DataFrame(all_suj_indiv_trial_probs[:, 2, :]).to_csv(basepath+"all_suj_high_correct_indiv_avg_probs.csv", index=False, header=None)
pd.DataFrame(all_suj_indiv_trial_probs[:, 3, :]).to_csv(basepath+"all_suj_high_incorrect_indiv_avg_probs.csv", index=False, header=None)
pd.DataFrame(all_suj_indiv_trial_probs[:, 0, :]).to_csv(basepath+"all_suj_low_correct_indiv_avg_probs.csv", index=False, header=None)
pd.DataFrame(all_suj_indiv_trial_probs[:, 1, :]).to_csv(basepath+"all_suj_low_incorrect_indiv_avg_probs.csv", index=False, header=None)

pd.DataFrame(all_suj_indiv_trial_preds[:, 2, :]).to_csv(basepath+"all_suj_high_correct_indiv_avg_preds.csv", index=False, header=None)
pd.DataFrame(all_suj_indiv_trial_preds[:, 3, :]).to_csv(basepath+"all_suj_high_incorrect_indiv_avg_preds.csv", index=False, header=None)
pd.DataFrame(all_suj_indiv_trial_preds[:, 0, :]).to_csv(basepath+"all_suj_low_correct_indiv_avg_preds.csv", index=False, header=None)
pd.DataFrame(all_suj_indiv_trial_preds[:, 1, :]).to_csv(basepath+"all_suj_low_incorrect_indiv_avg_preds.csv", index=False, header=None)