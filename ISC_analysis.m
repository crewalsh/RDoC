load('/Users/catherinewalsh/RDoC_mount/Catherine/ISC/fusiform_all_subjs.mat');

% split into events
tim = tim';
low_load_trials = cell(170,32);
high_load_trials = cell(170,32);

fprintf('All data extracted \n'); 

for suj = 1:10
    
    all_trial_onsets = [];
    
    low_count=1;
    high_count=1;
    
    all_trial_onsets = sort([onsets{suj,1}{1,1}; onsets{suj,1}{1,2}]);
    
    onsets_TRs = zeros(length(all_trial_onsets));
    
    %because trials are jittered, making it so the onset of a trial is just the
    %TR that contains the onset of the trial
    for i =1:length(all_trial_onsets)
        time_to_find = floor(all_trial_onsets(i)/1.5)*1.5;
        onsets_TRs(i) = find(tim ==time_to_find);
    end;
    
    for i = 1:length(onsets_TRs)
        temp_suj = all_data{suj,2}(onsets_TRs(i):onsets_TRs(i)+13,:);
        
        
        
        if ismember(all_trial_onsets(i),onsets{suj,1}{1,1})
            low_load_trials{suj,low_count} = temp_suj;
            
            
            low_count = low_count+1;
        else
            high_load_trials{suj,high_count} = temp_suj;
            
            high_count = high_count+1;
        end;
    end;
    
end;

fprintf('Data split into trials \n'); 

% average over trials

high_load_avg = cell(170,1);
low_load_avg = cell(170,1);

for suj = 1:10
    trial =1;
    suj_sum = zeros(14, length(high_load_trials{suj,1}));
    while ~isempty(high_load_trials{suj,trial})  && trial < 32
        suj_sum = suj_sum+high_load_trials{suj,trial};
        trial = trial + 1;
    end
    
    high_load_avg{suj,1} = suj_sum/(trial-1);
    
    trial =1;
    suj_sum = zeros(14, length(low_load_trials{suj,1}));
    while ~isempty(low_load_trials{suj,trial}) && trial < 32
        suj_sum = suj_sum+low_load_trials{suj,trial};
        trial = trial + 1;
    end
    
    low_load_avg{suj,1} = suj_sum/(trial-1);
    
    
end

fprintf('Data averaged over trials \n'); 

%calculate correlations

suj_corr = NaN(170,170,14);


for suj1 = 1:10
    for suj2 = 1:10
        for TR = 1:14
            
            
            % make sure have the same voxels and compute correlation
            % between each subject
            
            if length(all_data{suj1,1}) == length(all_data{suj2,1})
                if all_data{suj1,1} == all_data{suj2,1}
                    suj_corr(suj1,suj2,TR) = corr(high_load_avg{suj1,1}(TR,:)',high_load_avg{suj2,1}(TR,:)');
                end
            else
                common_coords = intersect(all_data{suj1,1},all_data{suj2,1},'rows');
                [tf,suj1_index] = ismember(common_coords,all_data{suj1,1},'rows');
                [tf,suj2_index] = ismember(common_coords,all_data{suj2,1},'rows');
                suj1_index = sort(suj1_index);
                suj2_index = sort(suj2_index);
                
                suj_corr(suj1,suj2,TR) = corr(high_load_avg{suj1,1}(TR,suj1_index)',high_load_avg{suj2,1}(TR,suj2_index)');
                
            end
        end
        
    end
end

fprintf('Data correlated across subjects \n'); 

% sort by WM capacity group

WM_groups = readtable('/Users/catherinewalsh/RDoC_mount/Catherine/walsh_scripts/WM_groups.csv');
WM_groups = WM_groups(:,2:3);
[sorted,sorted_by_group_idx] = sortrows(WM_groups,2);

suj_corr_sorted = suj_corr(sorted_by_group_idx,sorted_by_group_idx,:);

save('/Users/catherinewalsh/RDoC_mount/Catherine/ISC/ISC_corr.mat','suj_corr','suj_corr_sorted','sorted');
fprintf('Data sorted'); 