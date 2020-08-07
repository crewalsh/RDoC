cd data/EEG

files = dir;
files(ismember( {files.name}, {'.', '..','.DS_Store'})) = [];

for dir_num = 1:1
    
    cd(files(dir_num).name)
    
    filenames = dir;
    filenames(ismember({filenames.name}, {'.', '..','.DS_Store'})) = [];
    if files(dir_num).name == "LCD"
        filenames(ismember({filenames.name}, {'ERPS_CDA.txt'})) = [];
    end
    
    for file = 1:12
        
        filename = filenames(file).name;
        load(filename)
        
        PTID = str2num([vertcat(ERPS{1,1}.info.case); vertcat(ERPS{1,2}.info.case)]);
        
        low_data = cat(2,ERPS{1,1}.data_wtd,ERPS{1,2}.data_wtd);
        high_data = cat(2,ERPS{2,1}.data_wtd,ERPS{2,2}.data_wtd);
        
        low_data = cat(1, PTID', low_data)';
        high_data = cat(1,PTID', high_data)';
        
        all_data = {low_data,high_data};
        all_times = ERPS{1,1}.times;
        
        outfile = [filename(1:end-11) 'reformatted.mat'];
        save(outfile, 'all_data', 'all_times');
        
    end
    
    for file = 13:21
        
        filename = filenames(file).name;
        load(filename)
        PTID = str2num([vertcat(ERSPS{1,1}.info.case); vertcat(ERSPS{1,2}.info.case)]);
        
        low_data = cat(3,ERSPS{1,1}.data_wtd,ERSPS{1,2}.data_wtd);
        high_data = cat(3,ERSPS{2,1}.data_wtd,ERSPS{2,2}.data_wtd);
                
        all_data = {low_data,high_data};
        all_times = ERSPS{1,1}.times;
        all_freqs = ERSPS{1,1}.freqs;
        
        outfile = [filename(1:end-11) 'reformatted.mat'];
        save(outfile, 'all_data', 'all_times', 'all_freqs', 'PTID');
        
    end
    
    cd ../
end