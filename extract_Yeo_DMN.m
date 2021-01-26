im_roi              = '/u/project/rbilder/RDoC/Catherine/walsh_scripts/Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii';
im_roi = gunzip(im_roi);
vol_roi             = spm_vol(im_roi);
vol_roi = vol_roi{1,1};
[val_roi,xyz_roi]     = spm_read_vols(vol_roi);

%load in text file with names
fid = fopen('Schaefer2018_400Parcels_7Networks_order.txt');
txt = textscan(fid,'%s','delimiter','\n');
txt = txt{1,1};

for i = 1:400
    txt{i,1} = strsplit(txt{i,1});
end

cd /u/project/rbilder/RDoC/Catherine/Schaefer400_7Network_ROI

% create ROIs for L hemisphere

for ROI_idx = 149:200
    temp_ROI = val_roi==ROI_idx;
    vol_roi.fname = sprintf([txt{ROI_idx,1}{1,1},'_',txt{ROI_idx,1}{1,2},'.nii']);
    vol_roi.private.dat.fname = vol_roi.fname;
    spm_write_vol(vol_roi,temp_ROI);
end

% create ROIs for R hemisphere

for ROI_idx = 362:400
    temp_ROI = val_roi==ROI_idx;
    vol_roi.fname = sprintf([txt{ROI_idx,1}{1,1},'_',txt{ROI_idx,1}{1,2},'.nii']);
    vol_roi.private.dat.fname = vol_roi.fname;
    spm_write_vol(vol_roi,temp_ROI);
end

% create single ROI for full FPCN

full_ROI = zeros(91,109,91);

for ROI_idx = 149:200
    temp_ROI = val_roi==ROI_idx;
    full_ROI = full_ROI + temp_ROI;
end

for ROI_idx = 362:400
    temp_ROI = val_roi==ROI_idx;
    full_ROI = full_ROI + temp_ROI;
end;

vol_roi.fname = 'full_DMN.nii';
vol_roi.private.dat.fname = vol_roi.fname;
spm_write_vol(vol_roi,full_ROI);
