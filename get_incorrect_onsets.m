patsuj = '1002';
load('/u/project/rbilder/RDoC/scripts/fmri/Batch/pop200/pop200.mat');
run('/u/project/rbilder/RDoC/scripts/fmri/Batch/RDoC_SubjectToRemoveFromGroupAnalysis.m');
% suj_list = setdiff(pop200,suj2rem_DFR);

% load('/Users/catherinewalsh/RDoC_mount/scripts/fmri/Batch/pop200/pop200.mat');
% run('/Users/catherinewalsh/RDoC_mount/scripts/fmri/Batch/RDoC_SubjectToRemoveFromGroupAnalysis.m');
suj_list = setdiff(pop200,suj2rem_DFR);
Conditions  =  {'Cue_load1_Acc0','Cue_load3_Acc0'};
onsets = cell(170,1);

for suj = 1:170
    pat = ['/u/project/rbilder/RDoC/subjects/ID',num2str(suj_list(suj)),'/analysis/fMRI/SPM/DFR_Art_Model2/SPM.mat'];
    load(pat);
    for Cond=1:length(Conditions)
        idc = [];
        ons{Cond} = [];
        % get the onset in seconds
        tim  = [];
        for sess=1:length(SPM.Sess)
            idc = find(ismember([SPM.Sess(sess).U.name],Conditions{Cond}));
            if ~isempty(idc)
                ons{Cond} = [ons{Cond};[SPM.Sess(sess).U(idc).ons+SPM.nscan(sess)*TR*(sess-1)]];
            end
        end
    end
    onsets{suj} = ons;
    
end;
