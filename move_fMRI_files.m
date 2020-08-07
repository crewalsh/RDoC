cd /u/project/rbilder/RDoC/Catherine
mkdir compiled_fMRI

cd /u/project/rbilder/RDoC/subjects

load('/u/project/rbilder/RDoC/scripts/fmri/Batch/pop200/pop200.mat');
run('/u/project/rbilder/RDoC/scripts/fmri/Batch/RDoC_SubjectToRemoveFromGroupAnalysis.m');
suj_list = setdiff(pop200,suj2rem_DFR);

for suj = 1:1
%for suj=1:length(suj_list)
    mkdir(['/u/project/rbilder/RDoC/Catherine/compiled_fMRI/ID',int2str(suj)])
    filename = ['ID',suj,'/analysis/fMRI/SPM/'];
    
    cd filename
    for run =1:4
        outfile = ['../../../../../Catherine/compiled_fMRI/ID',suj,'/ID',int2str(suj),'_swrDFR_run',run,'.nii']; 
        copy_file = ['swrDFR_run',run','.nii'];
        copyfile(copy_file, outfile)
    end
    
    cd ../../../../
    
    
end