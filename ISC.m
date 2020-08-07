Name = 'ISC';
%2 subject pattern
patsuj = '1002';

%3 Output Directory
out = '/u/project/rbilder/RDoC/Catherine/ISC/';
%out = '/Users/catherinewalsh/RDoC_mount/Catherine/ISC/';
mkdir(out)

%4 Subject List
load('/u/project/rbilder/RDoC/scripts/fmri/Batch/pop200/pop200.mat');
run('/u/project/rbilder/RDoC/scripts/fmri/Batch/RDoC_SubjectToRemoveFromGroupAnalysis.m');
% suj_list = setdiff(pop200,suj2rem_DFR);

% load('/Users/catherinewalsh/RDoC_mount/scripts/fmri/Batch/pop200/pop200.mat');
% run('/Users/catherinewalsh/RDoC_mount/scripts/fmri/Batch/RDoC_SubjectToRemoveFromGroupAnalysis.m');
suj_list = setdiff(pop200,suj2rem_DFR);


%5 Conditions (see. SPM.Sess.U.name)
Conditions  =  {'Cue_load1_Acc1','Cue_load3_Acc1'};

%6 PSTH
Shift       = 2;
Length      = 18;

QuickY  = [];
output  = [];

%pre-allocate matrices
all_data = cell(170,2);


onsets = cell(170,3);

template_list = {'FvB'};

for template=1:numel(template_list)
    row_mark = 1;
    
    %for suj=1:10
    for suj=1:length(suj_list)
        pat = ['/u/project/rbilder/RDoC/subjects/ID',num2str(suj_list(suj)),'/analysis/fMRI/SPM/DFR_Art_Model2/SPM.mat'];
        %pat = ['/Users/catherinewalsh/RDoC_mount/subjects/ID',num2str(suj_list(suj)),'/analysis/fMRI/SPM/DFR_Art_Model2/SPM.mat'];
        
        load(pat);
        
        %ROImask = ['/u/project/rbilder/RDoC/Catherine/RSA/templates/bilateral_fusiform/',template_list{template},'/fusiform_masked_',template_list{template},'_',num2str(suj_list(suj)),'.nii'];
         ROImask = ['/u/project/rbilder/RDoC/Catherine/RSA/templates/DFR_Delay_full/',template_list{template},'_',num2str(suj_list(suj)),'.nii'];

        %ROImask = ['/Users/catherinewalsh/RDoC_mount/Catherine/RSA/templates/bilateral_fusiform/',template_list{template},'/fusiform_masked_',template_list{template},'_',num2str(suj_list(suj)),'.nii'];
        
        disp(['Mask use is: ',ROImask]);
        
        %load in ROI
        bthresh = 0.5;
        vol = spm_vol(ROImask);
        [vol0 xyz0] = spm_read_vols(vol);
        vol0(find(vol0>=bthresh))=1;
        % re-name header of the ROI loaded in
        Mvol = vol;
        % Mask_im now = the loaded in data
        Mask_im = vol0;
        
        % looping through image dimensions
        % transforming mask to individual subject space
        for j = 1:SPM.xVol.DIM(3)
            NewM = inv(spm_matrix([0 0 -j 0 0 0 1 1 1 ])*SPM.xVol.iM*Mvol.mat); % find the transformation from mask to SPM.xVol
            NewMask(:,:,j) = spm_slice_vol(Mask_im,NewM,SPM.xVol.DIM(1:2),0);   % reslice the mask after the transformation
        end
        
        % taking the big NewMask (which has many voxels of 0s) and finding only
        % voxels that actually have values
        Maskidx = find(NewMask);
        
        %put the one long string of numbers into xyz coordinates -- all still in
        %individual subject space
        z = ceil(Maskidx/(SPM.xVol.DIM(1)*SPM.xVol.DIM(2)));
        x = mod(mod(Maskidx, SPM.xVol.DIM(1)*SPM.xVol.DIM(2)), ...
            SPM.xVol.DIM(1));
        y = ceil(mod(Maskidx, SPM.xVol.DIM(1)*SPM.xVol.DIM(2))/ ...
            SPM.xVol.DIM(1));
        vol_idx = [x,y,z]';
        
        % putting us back into mm space
        Coord = SPM.xVol.M*[vol_idx;ones(1,size(vol_idx,2))];
        Coord(4,:) = [];
        Coord      = Coord';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ID          = suj_list(suj);
        SPM_file    = strrep(pat,patsuj,num2str(ID));
        file_out    = fullfile(out,[Name,'_',num2str(ID),'.mat']);
        disp(['Working on: ',file_out]);
        
        %get  TR
        TR = SPM.xX.K(1).RT;
        
        % Get the data files
        files = {SPM.xY.VY.fname}';
        
        % putting coord space back into subject space
        Coordtmp    = [Coord';ones(1,size(Coord,1))];
        IDxyz       = ceil(inv(SPM.xVol.M)*Coordtmp);
        IDxyz(4,:)  = [];
        % getting data for each time point
        Ye = spm_get_data(SPM.xY.VY,IDxyz);
        
        %%% Now do some processing and data cleaning %%%
        
        % Remove static and NaN
        ide = unique([find(std(Ye)==0) find(isnan(mean(Ye)))]);
        Ye(:,ide) = [];
        Coord(ide,:) = [];
        
        %  Remove the Cosinus and filter the data
        Yf = spm_filter(SPM.xX.K,Ye);
        
        YM = [];
        YS = [];
        Ym = [];
        Ys = [];
        
        % Reshape / Session / Detrend
        for i=1:length(SPM.xX.K)
            % get session indices
            m1 = min(SPM.xX.K(i).row);
            M1 = max(SPM.xX.K(i).row);
            
            % Normalize each voxel to a mean = 100
            Ys{i} = bsxfun(@rdivide,Yf(m1:M1,:),mean(Yf(m1:M1,:)))*100;
            
            % Transform into % change
            ts = Ys{i};m=mean(ts,1);T=size(ts,1);
            
            if(any(m<1e5*eps))
                ids=find(m<1e5*eps);
                m(ids)=max(abs(ts(:,ids)));
                ts(:,ids)=ts(:,ids)+repmat(m(ids),T,1);
            end
            y=100*(ts./repmat(m,T,1))-100;
            y(find(isnan(y)))=0;
            Ys{i} = y;
            
            
            % mean the value accros voxels
            if size(Ys{i},2)>1
                Ym{i} = mean(Ys{i}')';
            else
                Ym{i} = Ys{i};
            end
            
            % Reconstructed signal across session
            YM = [YM;Ym{i}];
            YS = [YS;Ys{i}];
        end
        
        rs = 1/10;
        
        onsR = [];
        % pull out timing of each event in seconds
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
                tim = [tim (SPM.nscan(sess)*(sess-1):(SPM.nscan(sess)*(sess)-1)).*TR];
                %onsR{Cond} = ons{Cond}*(1/rs);
            end
        end
        
        onsets{suj,template} = ons;
        all_data{suj,1} = Coord;
        all_data{suj,2} = YS;
        
    end
end


save('../ISC/DFR_delay_all_subjs.mat','onsets','tim','all_data','-v7.3');

tim = tim';
low_load_trials = cell(170,32);
high_load_trials = cell(170,32);

fprintf('All data extracted \n');

%load('data/fusiform_all_subjs.mat'); 

for suj = 1:170
    
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

for suj = 1:170
    trial =1;
    suj_sum = zeros(14, length(high_load_trials{suj,1}));
    while ~isempty(high_load_trials{suj,trial})  && trial < 31
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


for suj1 = 1:170
    for suj2 = 1:170
        for TR = 1:14
            
            
            % make sure have the same voxels and compute correlation
            % between each subject
            
            if length(all_data{suj1,1}) == length(all_data{suj2,1})
                if all_data{suj1,1} == all_data{suj2,1}
                    suj_corr(suj1,suj2,TR) = corr(high_load_avg{suj1,1}(TR,:)',high_load_avg{suj2,1}(TR,:)','rows','complete');
                end
            else
                common_coords = intersect(all_data{suj1,1},all_data{suj2,1},'rows');
                [tf,suj1_index] = ismember(common_coords,all_data{suj1,1},'rows');
                [tf,suj2_index] = ismember(common_coords,all_data{suj2,1},'rows');
                suj1_index = sort(suj1_index);
                suj2_index = sort(suj2_index);
                
                suj_corr(suj1,suj2,TR) = corr(high_load_avg{suj1,1}(TR,suj1_index)',high_load_avg{suj2,1}(TR,suj2_index)','rows','complete');
                
            end
        end
        
    end
end

full_coord_list = all_data{1,1};
full_data = NaN(884,4808,170); 


for suj = 1:170
    
  if length(intersect(full_coord_list,all_data{suj,1},'rows')) == 4808
     full_data(:,:,suj) = all_data{suj,2};  
  else
      temp = NaN(884,4808);
      temp(:,ismember(full_coord_list,all_data{suj,1},'rows')) = all_data{suj,2};
      full_data(:,:,suj) = temp;
      
  end
    
    
end

fprintf('Data correlated across subjects \n');

% sort by WM capacity group

WM_groups = readtable('/u/project/rbilder/RDoC/Catherine/walsh_scripts/WM_groups.csv');
WM_groups = WM_groups(:,2:3);
[sorted,sorted_by_group_idx] = sortrows(WM_groups,2);

suj_corr_sorted = suj_corr(sorted_by_group_idx,sorted_by_group_idx,:);

%sort by span
WM_span = readtable('/u/project/rbilder/RDoC/Catherine/ISC/span_sorted.csv');
WM_span = WM_span(:,2:3);
WM_span = sortrows(WM_span,1);
[sorted_span,sorted_by_span_idx] = sortrows(WM_span,2);

suj_corr_sorted_by_span = suj_corr(sorted_by_span_idx,sorted_by_span_idx,:);

fprintf('Data sorted');

figure;

for TR = 1:14
    hold on
    imagesc(suj_corr_sorted_by_span(:,:,TR));
    colorbar
    colormap jet
    yline(56);
    yline(113);
    yline(168);
    xline(56);
    xline(113);
    xline(168);
    %     hline = refline([0 56]); % high vs low boundary
    %     hline_2 = refline([0 113]); % low vs med boundary
    %     hline_3 = refline([0 168]); % med vs not incl boundary
    %     %    vline = refline([56 0]);
    %     %    vline_2 = refline([113 0]);
    %     %    vline_3 = refline([168 0]);
    hold off;
    title(num2str(TR));
    pause;
end

% calculate correlations within and between groups

group_correlations = NaN(3,3,14);
avg_group_correlations = NaN(3,14);

for TR = 1:14
    group_correlations(1,1,TR) = mean(nanmean(suj_corr_sorted(57:112,57:112,TR),1)); %low to low
    group_correlations(1,2,TR) = mean(nanmean(suj_corr_sorted(57:112,113:168,TR),1)); %low to med
    group_correlations(1,3,TR) = mean(nanmean(suj_corr_sorted(57:112,1:56,TR),1)); %low to high
    group_correlations(2,1,TR) = mean(nanmean(suj_corr_sorted(113:168,57:112,TR),1)); % med to low
    group_correlations(2,2,TR) = mean(nanmean(suj_corr_sorted(113:168,113:168,TR),1)); % med to med
    group_correlations(2,3,TR) = mean(nanmean(suj_corr_sorted(113:168,1:56,TR),1)); % med to high
    group_correlations(3,1,TR) = mean(nanmean(suj_corr_sorted(57:112,1:56,TR),1)); % high to low
    group_correlations(3,2,TR) = mean(nanmean(suj_corr_sorted(113:168,1:56,TR),1)); % high to med
    group_correlations(3,3,TR) = mean(nanmean(suj_corr_sorted(1:56,1:56,TR),1)); % high to high
    
    % within group comparisons
    avg_group_correlations(1,TR) = (group_correlations(1,1,TR)+group_correlations(2,2,TR)+ group_correlations(3,3,TR))/3;
    
    % between group comparisons
    avg_group_correlations(2,TR) = (group_correlations(1,2,TR)+group_correlations(1,3,TR)+group_correlations(2,3,TR))/3;
    avg_group_correlations(3,TR) = TR;
end


figure;
plot(avg_group_correlations(3,:),avg_group_correlations(1,:));
hold on
plot(avg_group_correlations(3,:),avg_group_correlations(2,:));

% t test for each time point

z_trans_corr = atanh(suj_corr_sorted);

t_test_res = NaN(14,2); 

for TR = 1:14
    within_suj_comp = [z_trans_corr(1:56,1:56,TR),z_trans_corr(57:112,57:112,TR),z_trans_corr(113:168,113:168,TR)];
    across_suj_comp = [z_trans_corr(1:56,57:112,TR),z_trans_corr(1:56,113:168,TR),z_trans_corr(57:112,113:168,TR)];
    within_suj_comp = reshape(within_suj_comp,numel(within_suj_comp),1);
    across_suj_comp = reshape(across_suj_comp,numel(across_suj_comp),1);
    within_suj_comp(within_suj_comp==Inf) = NaN;
    within_suj_comp(within_suj_comp==Inf) = NaN;
    [H,P] = ttest2(within_suj_comp,across_suj_comp); 
    t_test_res(TR,:) = [H,P];
    
end


save('/u/project/rbilder/RDoC/Catherine/ISC/ISC_corr_DFR_delay.mat','suj_corr','suj_corr_sorted','suj_corr_sorted_by_span','sorted','z_trans_corr');


