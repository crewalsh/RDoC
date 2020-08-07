load('/Volumes/Work/UCLA/RDoC/DFR_delay_all_subjs.mat');
load('data/incorrect_onsets.mat');

tim = tim';
low_load_trials_correct = cell(170,32);
high_load_trials_correct = cell(170,32);
low_load_trials_incorrect = cell(170,32);
high_load_trials_incorrect = cell(170,32);

all_corrs = NaN(170,64,14);

encoding_to_delay_corr = NaN(170,64);
encoding_to_correct_delay = NaN(170,64);
correct_encoding_to_delay = NaN(170,64);
correct_encoding_to_correct_delay = NaN(170,1);

encoding_to_probe_corr = NaN(170,64);
encoding_to_correct_probe = NaN(170,64);
correct_encoding_to_probe = NaN(170,64);
correct_encoding_to_correct_probe = NaN(170,1);

delay_to_probe_corr = NaN(170,64);
delay_to_correct_probe = NaN(170,64);
correct_delay_to_probe = NaN(170,64);
correct_delay_to_correct_probe = NaN(170,1);

high_correct_avg = zeros(170,14);
high_incorrect_avg = zeros(170,14);
low_correct_avg = zeros(170,14);
low_incorrect_avg = zeros(170,14);

encoding_to_delay_avg = zeros(170,4);
encoding_to_correct_delay_avg = zeros(170,4);
correct_encoding_to_delay_avg = zeros(170,4);

encoding_to_probe_avg = zeros(170,4);
encoding_to_correct_probe_avg = zeros(170,4);
correct_encoding_to_probe_avg = zeros(170,4);

delay_to_probe_avg = zeros(170,4);
delay_to_correct_probe_avg = zeros(170,4);
correct_delay_to_probe_avg = zeros(170,4);

for suj = 1:170
    
    all_trial_onsets = sort([onsets{suj,1}{1,1}; onsets{suj,1}{1,2};
        incorr_ons{suj}{1,1}; incorr_ons{suj}{1,2}]);
    
    %because trials are jittered, making it so the onset of a trial is just the
    %TR that contains the onset of the trial
    onsets_TRs = NaN(64,1);
    for i =1:64
        time_to_find = floor(all_trial_onsets(i)/1.5)*1.5;
        onsets_TRs(i) = find(tim ==time_to_find);
    end
    
    low_count_correct = 1;
    high_count_correct = 1;
    low_count_incorrect = 1;
    high_count_incorrect = 1;
    
    
    for i = 1:64
        temp_suj = all_data{suj,2}(onsets_TRs(i):onsets_TRs(i)+13,:);
        
        %separate trials into separate lists based on load and accuracy
        
        if ismember(all_trial_onsets(i),onsets{suj,1}{1,1})
            low_load_trials_correct{suj,low_count_correct} = temp_suj;
            low_count_correct = low_count_correct+1;
        elseif ismember(all_trial_onsets(i),onsets{suj,1}{1,2})
            high_load_trials_correct{suj,high_count_correct} = temp_suj;
            high_count_correct = high_count_correct+1;
        elseif ismember(all_trial_onsets(i),incorr_ons{suj}{1,1})
            low_load_trials_incorrect{suj,low_count_incorrect} = temp_suj;
            low_count_incorrect = low_count_incorrect+1;
        else
            high_load_trials_incorrect{suj,high_count_incorrect} = temp_suj;
            high_count_incorrect = high_count_incorrect+1;
        end
    end
    fprintf('Data split into trials for subject %i \n', suj);
    
    
    % all all correct trials up - we'll average this later
    correct_sum = [];
    correct_sum = high_load_trials_correct{suj,1};
    correct_count = 1;
    for trial = 2:32
        if ~isempty(high_load_trials_correct{suj,trial})
            correct_sum = correct_sum+ high_load_trials_correct{suj,trial};
            correct_count = correct_count + 1;
        end
    end
    for trial = 1:32
        if ~isempty(low_load_trials_correct{suj,trial})
            correct_sum = correct_sum+ low_load_trials_correct{suj,trial};
            correct_count = correct_count + 1;
        end
    end
    
    
    % first, let's look at the correlation between TRs just within the template
    
    correct_template = correct_sum/correct_count;
    correct_encoding_to_correct_delay(suj,1) = corr(correct_template(5,:)',correct_template(8,:)');
    correct_encoding_to_correct_probe(suj,1) = corr(correct_template(5,:)',correct_template(11,:)');
    correct_delay_to_correct_probe(suj,1) = corr(correct_template(8,:)',correct_template(11,:)');
    
    
    % now, let's look at the individual trials
    for i = 1:64
        % first, let's look at incorrect trials - these just need to be
        % compared to all the average of all correct trials
        
        % low load incorrect
        if ismember(all_trial_onsets(i),incorr_ons{suj}{1,1})
            correct_template = correct_sum/correct_count;
            trial = find(incorr_ons{suj,1}{1,1}==all_trial_onsets(i));
            temp_data = low_load_trials_incorrect{suj,trial};
            % high load incorrect
        elseif ismember(all_trial_onsets(i),incorr_ons{suj}{1,2})
            correct_template = correct_sum/correct_count;
            trial = find(incorr_ons{suj,1}{1,2}==all_trial_onsets(i));
            temp_data = high_load_trials_incorrect{suj,trial};
            
            % it it's a correct trial, however, we need to remove that trial
            % from the average before we can compare it
            % low load correct
        elseif ismember(all_trial_onsets(i),onsets{suj}{1,1})
            trial = find(onsets{suj,1}{1,1}==all_trial_onsets(i));
            temp_data = low_load_trials_correct{suj,trial};
            correct_template = (correct_sum - temp_data)/(correct_count-1);
            % high load correct
        elseif ismember(all_trial_onsets(i),onsets{suj}{1,2})
            trial = find(onsets{suj,1}{1,2}==all_trial_onsets(i));
            temp_data = high_load_trials_correct{suj,trial};
            correct_template = (correct_sum - temp_data)/(correct_count-1);
        end
        
        % correlate trial to template
        for TR = 1:14
            all_corrs(suj,i,TR) = corr(temp_data(TR,:)',correct_template(TR,:)');
        end
        
        % compare encoding representation to delay for each individual
        % trial and also to the template
        encoding_to_delay_corr(suj,i) = corr(temp_data(5,:)',temp_data(8,:)');
        encoding_to_correct_delay(suj,i) = corr(temp_data(5,:)',correct_template(8,:)');
        correct_encoding_to_delay(suj,i) = corr(temp_data(8,:)',correct_template(5,:)');
        
        % encoding to probe
        encoding_to_probe_corr(suj,i) = corr(temp_data(5,:)',temp_data(11,:)');
        encoding_to_correct_probe(suj,i) = corr(temp_data(5,:)',correct_template(11,:)');
        correct_encoding_to_probe(suj,i) = corr(temp_data(11,:)',correct_template(5,:)');
        
        % delay to probe
        delay_to_probe_corr(suj,i) = corr(temp_data(11,:)',temp_data(8,:)');
        delay_to_correct_probe(suj,i) = corr(temp_data(11,:)',correct_template(8,:)');
        correct_delay_to_probe(suj,i) = corr(temp_data(8,:)',correct_template(11,:)');
        
    end
    
    fprintf('correlated subject %i \n', suj);
    
    % now let's split back out into correct and incorrect trials, high and low
    
    for i = 1:64
        % low load incorrect
        if ismember(all_trial_onsets(i),incorr_ons{suj}{1,1})
            low_incorrect_avg(suj,:) = low_incorrect_avg(suj,:) + squeeze(all_corrs(suj,i,:))';
            % encoding to delay
            encoding_to_delay_avg(suj,1) = encoding_to_delay_avg(suj,1) + encoding_to_delay_corr(suj,i);
            correct_encoding_to_delay_avg(suj,1) = correct_encoding_to_delay_avg(suj,1) + correct_encoding_to_delay(suj,i);
            encoding_to_correct_delay_avg(suj,1) = encoding_to_correct_delay_avg(suj,1) + encoding_to_correct_delay(suj,i);
            
            % encoding to probe
            encoding_to_probe_avg(suj,1) = encoding_to_probe_avg(suj,1) + encoding_to_probe_corr(suj,i);
            correct_encoding_to_probe_avg(suj,1) = correct_encoding_to_probe_avg(suj,1) + correct_encoding_to_probe(suj,i);
            encoding_to_correct_probe_avg(suj,1) = encoding_to_correct_probe_avg(suj,1) + encoding_to_correct_probe(suj,i);
            
            % delay to probe
            delay_to_probe_avg(suj,1) = delay_to_probe_avg(suj,1) + delay_to_probe_corr(suj,i);
            correct_delay_to_probe_avg(suj,1) = correct_delay_to_probe_avg(suj,1) + correct_delay_to_probe(suj,i);
            delay_to_correct_probe_avg(suj,1) = delay_to_correct_probe_avg(suj,1) + delay_to_correct_probe(suj,i);
            
            % high load incorrect
        elseif ismember(all_trial_onsets(i),incorr_ons{suj}{1,2})
            high_incorrect_avg(suj,:) = high_incorrect_avg(suj,:)+ squeeze(all_corrs(suj,i,:))';
            encoding_to_delay_avg(suj,2) = encoding_to_delay_avg(suj,2) + encoding_to_delay_corr(suj,i);
            correct_encoding_to_delay_avg(suj,2) = correct_encoding_to_delay_avg(suj,2) + correct_encoding_to_delay(suj,i);
            encoding_to_correct_delay_avg(suj,2) = encoding_to_correct_delay_avg(suj,2) + encoding_to_correct_delay(suj,i);
            
            % encoding to probe
            encoding_to_probe_avg(suj,2) = encoding_to_probe_avg(suj,2) + encoding_to_probe_corr(suj,i);
            correct_encoding_to_probe_avg(suj,2) = correct_encoding_to_probe_avg(suj,2) + correct_encoding_to_probe(suj,i);
            encoding_to_correct_probe_avg(suj,2) = encoding_to_correct_probe_avg(suj,2) + encoding_to_correct_probe(suj,i);
            
            % delay to probe
            delay_to_probe_avg(suj,2) = delay_to_probe_avg(suj,2) + delay_to_probe_corr(suj,i);
            correct_delay_to_probe_avg(suj,2) = correct_delay_to_probe_avg(suj,2) + correct_delay_to_probe(suj,i);
            delay_to_correct_probe_avg(suj,2) = delay_to_correct_probe_avg(suj,2) + delay_to_correct_probe(suj,i);
            
            % low load correct
        elseif ismember(all_trial_onsets(i),onsets{suj,1}{1,1})
            low_correct_avg(suj,:) = low_correct_avg(suj,:)+ squeeze(all_corrs(suj,i,:))';
            encoding_to_delay_avg(suj,3) = encoding_to_delay_avg(suj,1) + encoding_to_delay_corr(suj,i);
            correct_encoding_to_delay_avg(suj,3) = correct_encoding_to_delay_avg(suj,3) + correct_encoding_to_delay(suj,i);
            encoding_to_correct_delay_avg(suj,3) = encoding_to_correct_delay_avg(suj,3) + encoding_to_correct_delay(suj,i);
            
            % encoding to probe
            encoding_to_probe_avg(suj,3) = encoding_to_probe_avg(suj,3) + encoding_to_probe_corr(suj,i);
            correct_encoding_to_probe_avg(suj,3) = correct_encoding_to_probe_avg(suj,3) + correct_encoding_to_probe(suj,i);
            encoding_to_correct_probe_avg(suj,3) = encoding_to_correct_probe_avg(suj,3) + encoding_to_correct_probe(suj,i);
            
            % delay to probe
            delay_to_probe_avg(suj,3) = delay_to_probe_avg(suj,3) + delay_to_probe_corr(suj,i);
            correct_delay_to_probe_avg(suj,3) = correct_delay_to_probe_avg(suj,3) + correct_delay_to_probe(suj,i);
            delay_to_correct_probe_avg(suj,3) = delay_to_correct_probe_avg(suj,3) + delay_to_correct_probe(suj,i);
            
            % high load correct
        elseif ismember(all_trial_onsets(i),onsets{suj,1}{1,2})
            high_correct_avg(suj,:) = high_correct_avg(suj,:)+ squeeze(all_corrs(suj,i,:))';
            encoding_to_delay_avg(suj,4) = encoding_to_delay_avg(suj,4) + encoding_to_delay_corr(suj,i);
            correct_encoding_to_delay_avg(suj,4) = correct_encoding_to_delay_avg(suj,4) + correct_encoding_to_delay(suj,i);
            encoding_to_correct_delay_avg(suj,4) = encoding_to_correct_delay_avg(suj,4) + encoding_to_correct_delay(suj,i);
            
            % encoding to probe
            encoding_to_probe_avg(suj,4) = encoding_to_probe_avg(suj,4) + encoding_to_probe_corr(suj,i);
            correct_encoding_to_probe_avg(suj,4) = correct_encoding_to_probe_avg(suj,4) + correct_encoding_to_probe(suj,i);
            encoding_to_correct_probe_avg(suj,4) = encoding_to_correct_probe_avg(suj,4) + encoding_to_correct_probe(suj,i);
            
            % delay to probe
            delay_to_probe_avg(suj,4) = delay_to_probe_avg(suj,4) + delay_to_probe_corr(suj,i);
            correct_delay_to_probe_avg(suj,4) = correct_delay_to_probe_avg(suj,4) + correct_delay_to_probe(suj,i);
            delay_to_correct_probe_avg(suj,4) = delay_to_correct_probe_avg(suj,4) + delay_to_correct_probe(suj,i);
            
        end
    end
    
    low_incorrect_avg(suj,:) = low_incorrect_avg(suj,:)/low_count_incorrect;
    high_incorrect_avg(suj,:) = high_incorrect_avg(suj,:)/high_count_incorrect;
    low_correct_avg(suj,:) = low_correct_avg(suj,:)/low_count_correct;
    high_correct_avg(suj,:) = high_correct_avg(suj,:)/high_count_correct;
    
    encoding_to_delay_avg(suj,1) = encoding_to_delay_avg(suj,1)/low_count_incorrect;
    encoding_to_delay_avg(suj,2) = encoding_to_delay_avg(suj,2)/high_count_incorrect;
    encoding_to_delay_avg(suj,3) = encoding_to_delay_avg(suj,3)/low_count_correct;
    encoding_to_delay_avg(suj,4) = encoding_to_delay_avg(suj,4)/high_count_correct;
    
    correct_encoding_to_delay_avg(suj,1) = correct_encoding_to_delay_avg(suj,1)/low_count_incorrect;
    correct_encoding_to_delay_avg(suj,2) = correct_encoding_to_delay_avg(suj,2)/high_count_incorrect;
    correct_encoding_to_delay_avg(suj,3) = correct_encoding_to_delay_avg(suj,3)/low_count_correct;
    correct_encoding_to_delay_avg(suj,4) = correct_encoding_to_delay_avg(suj,4)/high_count_correct;
    
    encoding_to_correct_delay_avg(suj,1) = encoding_to_correct_delay_avg(suj,1)/low_count_incorrect;
    encoding_to_correct_delay_avg(suj,2) = encoding_to_correct_delay_avg(suj,2)/high_count_incorrect;
    encoding_to_correct_delay_avg(suj,3) = encoding_to_correct_delay_avg(suj,3)/low_count_correct;
    encoding_to_correct_delay_avg(suj,4) = encoding_to_correct_delay_avg(suj,4)/high_count_correct;
    
    % encoding to probe
    
    encoding_to_probe_avg(suj,1) = encoding_to_probe_avg(suj,1)/low_count_incorrect;
    encoding_to_probe_avg(suj,2) = encoding_to_probe_avg(suj,2)/high_count_incorrect;
    encoding_to_probe_avg(suj,3) = encoding_to_probe_avg(suj,3)/low_count_correct;
    encoding_to_probe_avg(suj,4) = encoding_to_probe_avg(suj,4)/high_count_correct;
    
    correct_encoding_to_probe_avg(suj,1) = correct_encoding_to_probe_avg(suj,1)/low_count_incorrect;
    correct_encoding_to_probe_avg(suj,2) = correct_encoding_to_probe_avg(suj,2)/high_count_incorrect;
    correct_encoding_to_probe_avg(suj,3) = correct_encoding_to_probe_avg(suj,3)/low_count_correct;
    correct_encoding_to_probe_avg(suj,4) = correct_encoding_to_probe_avg(suj,4)/high_count_correct;
    
    encoding_to_correct_probe_avg(suj,1) = encoding_to_correct_probe_avg(suj,1)/low_count_incorrect;
    encoding_to_correct_probe_avg(suj,2) = encoding_to_correct_probe_avg(suj,2)/high_count_incorrect;
    encoding_to_correct_probe_avg(suj,3) = encoding_to_correct_probe_avg(suj,3)/low_count_correct;
    encoding_to_correct_probe_avg(suj,4) = encoding_to_correct_probe_avg(suj,4)/high_count_correct;
    
    % delay to probe
    
    delay_to_probe_avg(suj,1) = delay_to_probe_avg(suj,1)/low_count_incorrect;
    delay_to_probe_avg(suj,2) = delay_to_probe_avg(suj,2)/high_count_incorrect;
    delay_to_probe_avg(suj,3) = delay_to_probe_avg(suj,3)/low_count_correct;
    delay_to_probe_avg(suj,4) = delay_to_probe_avg(suj,4)/high_count_correct;
    
    correct_delay_to_probe_avg(suj,1) = correct_delay_to_probe_avg(suj,1)/low_count_incorrect;
    correct_delay_to_probe_avg(suj,2) = correct_delay_to_probe_avg(suj,2)/high_count_incorrect;
    correct_delay_to_probe_avg(suj,3) = correct_delay_to_probe_avg(suj,3)/low_count_correct;
    correct_delay_to_probe_avg(suj,4) = correct_delay_to_probe_avg(suj,4)/high_count_correct;
    
    delay_to_correct_probe_avg(suj,1) = delay_to_correct_probe_avg(suj,1)/low_count_incorrect;
    delay_to_correct_probe_avg(suj,2) = delay_to_correct_probe_avg(suj,2)/high_count_incorrect;
    delay_to_correct_probe_avg(suj,3) = delay_to_correct_probe_avg(suj,3)/low_count_correct;
    delay_to_correct_probe_avg(suj,4) = delay_to_correct_probe_avg(suj,4)/high_count_correct;
    
    
    fprintf('averaged high and low trials for subject %i \n',suj);
end

corr_order = {'low load incorrect','high load incorrect', 'low load correct','high load correct'};

save('data/intertrial_similarity_DFR.mat','encoding_to_probe_avg', 'correct_encoding_to_probe_avg',...
    'encoding_to_correct_probe_avg','correct_encoding_to_correct_probe',...
    'delay_to_probe_avg','correct_delay_to_probe_avg','delay_to_correct_probe_avg',...
    'correct_delay_to_correct_probe','low_incorrect_avg','high_incorrect_avg',...
    'low_correct_avg','high_correct_avg', 'encoding_to_delay_avg', 'correct_encoding_to_delay_avg',...
    'encoding_to_correct_delay_avg','correct_encoding_to_correct_delay','corr_order')

