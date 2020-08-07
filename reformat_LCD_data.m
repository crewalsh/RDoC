cd data/EEG/LCD

files = dir;
files(ismember( {files.name}, {'.', '..','.DS_Store','ERPS_CDA.txt'})) = [];

for file = 1:2
        
        filename = files(file).name;
        load(filename)
        
        PTID = str2num([vertcat(ERPS{1,1}.info.case); vertcat(ERPS{1,2}.info.case)]);
        
        L1_data = cat(2,ERPS{1,1}.data_wtd,ERPS{1,2}.data_wtd);
        R1_data = cat(2,ERPS{2,1}.data_wtd,ERPS{2,2}.data_wtd);
        
        L3_data = cat(2,ERPS{3,1}.data_wtd,ERPS{3,2}.data_wtd);
        R3_data = cat(2,ERPS{4,1}.data_wtd,ERPS{4,2}.data_wtd);
        
        L5_data = cat(2,ERPS{5,1}.data_wtd,ERPS{5,2}.data_wtd);
        R5_data = cat(2,ERPS{6,1}.data_wtd,ERPS{6,2}.data_wtd);
        
        L1_data = cat(1,PTID',L1_data)';
        R1_data = cat(1,PTID',R1_data)';
        L3_data = cat(1,PTID',L3_data)';
        R3_data = cat(1,PTID',R3_data)';
        L5_data = cat(1,PTID',L5_data)';
        R5_data = cat(1,PTID',R5_data)';
        
        all_data = {L1_data,R1_data,L3_data,R3_data,L5_data,R5_data};
        all_times = ERPS{1,1}.times;
        
        outfile = [filename(1:end-11) 'reformatted.mat'];
        save(outfile, 'all_data', 'all_times');
        
end
    
for file = 3:4
        
        filename = files(file).name;
        load(filename)
        PTID = str2num([vertcat(ERSPS{1,1}.info.case); vertcat(ERSPS{1,2}.info.case)]);
        
        L1_data = cat(3,ERSPS{1,1}.data_wtd,ERSPS{1,2}.data_wtd);
        R1_data = cat(3,ERSPS{2,1}.data_wtd,ERSPS{2,2}.data_wtd);
        
        L3_data = cat(3,ERSPS{3,1}.data_wtd,ERSPS{3,2}.data_wtd);
        R3_data = cat(3,ERSPS{4,1}.data_wtd,ERSPS{4,2}.data_wtd);
        
        L5_data = cat(3,ERSPS{5,1}.data_wtd,ERSPS{5,2}.data_wtd);
        R5_data = cat(3,ERSPS{6,1}.data_wtd,ERSPS{6,2}.data_wtd);
                
        all_data = {L1_data,R1_data,L3_data,R3_data,L5_data,R5_data};
        all_times = ERSPS{1,1}.times;
        all_freqs = ERSPS{1,1}.freqs;
        
        outfile = [filename(1:end-11) 'reformatted.mat'];
        save(outfile, 'all_data', 'all_times', 'all_freqs', 'PTID');
        
end