%% do WBSM
addpath('analysis tools');

DFR_labels = zeros(52,170);
rest_labels = zeros(52, 170);

n=52;
M= n*(n-1)/2;

for suj = 1:170
    DFR_labels(:, suj) = wsbm(FPCN_submatrix_DFR(:,:,suj),2);
    rest_labels(:, suj) = wsbm(FPCN_submatrix_rest(:,:,suj),2);
end

fprintf("finished WSBM \n");

%% calculate rand index for DFR
rand_index_DFR = nan(170);
rand_index_rest = nan(170);

% do for DFR
for sub1 = 1:170
    for sub2 = 1:170
        % reset values
        M1 = 0;
        M2 = 0;
        w = 0;
        
        % create contingency table
        cont = zeros(2,2);
        
        for item = 1:52
            
            % create contingency table
            if (DFR_labels(item,sub1) == 1) && (DFR_labels(item,sub2) == 1)
                cont(1,1) = cont(1,1) + 1;
            elseif (DFR_labels(item,sub1) == 1) && (DFR_labels(item,sub2) == 2)
                cont(1,2) = cont(1,2) +1;
            elseif (DFR_labels(item,sub1) == 2) && (DFR_labels(item,sub2) == 1)
                cont(2,1) = cont(2,1)+1;
            elseif (DFR_labels(item,sub1) == 2) && (DFR_labels(item,sub2) == 2)
                cont(2,2) = cont(2,2) +1;
            end
            
        end
        
        % count how many pairs were labeled the same group across and
        % within partitions
        for pair1 = 1:51
            for pair2 = (pair1+1):52
                if DFR_labels(pair1,sub1) == DFR_labels(pair2,sub1)
                    M1 = M1+1;
                end
                if DFR_labels(pair1,sub2) == DFR_labels(pair2,sub2)
                    M2 = M2+1;
                end
                
                if (DFR_labels(pair1,sub1) == DFR_labels(pair2,sub1)) == ( DFR_labels(pair1,sub2) == DFR_labels(pair2,sub2) )
                    w = w+1;
                end
                
            end
        end
        
        % calculate rand z score
        a1 = cont(1,1) + cont(1,2);
        a2 = cont(2,1) + cont(2,2);
        b1 = cont(1,1) + cont(2,1);
        b2 = cont(1,2)+ cont(2,2);
        
        temp_m1 = (4*M1 - (2*M))^2;
        temp_m2 = (4*M2 - (2*M))^2;
        
        c1 = (n*(n^2 - 3*n -2)) - (8*(n+1)*M1) + (4*(a1^3 + a2^3));
        c2 =  n*(n^2 - 3*n -2) - 8*(n+1)*M2 + 4*(b1^3 + b2^3);
        
        sigma_w_sq = (M/16) - (temp_m1*temp_m2)/(256*(M^2)) + ...
            ((c1*c2)/(16*n*(n-1)*(n-2))) + ...
            ((temp_m1 - (4*c1) - (4*M))*(temp_m2 - (4*c2) - (4*M)))/ ...
            (64*n*(n-1)*(n-2)*(n-3));
        
        
        rand_index_DFR(sub1, sub2) = (w - (M1*M2/M))/sqrt(sigma_w_sq);
        
    end
    fprintf("finished DFR for subject %f \n", sub1);
end

fprintf("finished DFR \n");

%% calculate rand index for rest

for sub1 = 1:170
    for sub2 = 1:170
        % reset values
        M1 = 0;
        M2 = 0;
        w = 0;
        
        % create contingency table
        cont = zeros(2,2);
        
        for item = 1:52
            
            % create contingency table
            if (rest_labels(item,sub1) == 1) && (rest_labels(item,sub2) == 1)
                cont(1,1) = cont(1,1) + 1;
            elseif (rest_labels(item,sub1) == 1) && (rest_labels(item,sub2) == 2)
                cont(1,2) = cont(1,2) +1;
            elseif (rest_labels(item,sub1) == 2) && (rest_labels(item,sub2) == 1)
                cont(2,1) = cont(2,1)+1;
            elseif (rest_labels(item,sub1) == 2) && (rest_labels(item,sub2) == 2)
                cont(2,2) = cont(2,2) +1;
            end
            
        end
        
        % count how many pairs were labeled the same
        for pair1 = 1:51
            for pair2 = (pair1+1):52
                if rest_labels(pair1,sub1) == rest_labels(pair2,sub1)
                    M1 = M1+1;
                end
                if rest_labels(pair1,sub2) == rest_labels(pair2,sub2)
                    M2 = M2+1;
                end
                
                if (rest_labels(pair1,sub1) == rest_labels(pair2,sub1)) == ( rest_labels(pair1,sub2) == rest_labels(pair2,sub2) )
                    w = w+1;
                end
                
            end
        end
        
        % calculate rand z score
        a1 = cont(1,1) + cont(1,2);
        a2 = cont(2,1) + cont(2,2);
        b1 = cont(1,1) + cont(2,1);
        b2 = cont(1,2)+ cont(2,2);
        
        temp_m1 = (4*M1 - (2*M))^2;
        temp_m2 = (4*M2 - (2*M))^2;
        
        c1 = (n*(n^2 - 3*n -2)) - (8*(n+1)*M1) + (4*(a1^3 + a2^3));
        c2 =  n*(n^2 - 3*n -2) - 8*(n+1)*M2 + 4*(b1^3 + b2^3);
        
        sigma_w_sq = (M/16) - (temp_m1*temp_m2)/(256*(M^2)) + ...
            ((c1*c2)/(16*n*(n-1)*(n-2))) + ...
            ((temp_m1 - (4*c1) - (4*M))*(temp_m2 - (4*c2) - (4*M)))/ ...
            (64*n*(n-1)*(n-2)*(n-3));
        
        rand_index_rest(sub1, sub2) = (w - M1*M2/M)/sqrt(sigma_w_sq);
        
    end
    fprintf("finished rest for subject %f \n", sub1);
    
end


%% remove similarity to self 

for sub = 1:170
   rand_index_DFR(sub,sub) = NaN;
   rand_index_rest(sub,sub) = NaN;
end

% for rest, also need to remove subjects 1024 and 1554 since something got
% weird with their data so they didn't have it 

rand_index_rest([11,72],:) = NaN; 
rand_index_rest(:,[11,72]) = NaN; 


%% calculate average sim for each subj 

avg_sim_DFR = NaN(170,1);
avg_sim_rest = NaN(170,1); 

for sub = 1:170
    avg_sim_DFR(sub) = nanmean(rand_index_DFR(sub,:)); 
    avg_sim_rest(sub) = nanmean(rand_index_rest(sub,:)); 

end

%% find max sim value 

max_sim_DFR_idx = find(avg_sim_DFR == max(avg_sim_DFR)); 
max_sim_rest_idx = find(avg_sim_rest == max(avg_sim_rest)); 

%% compare most sim labels 

compare_DFR_rest_labels = [DFR_labels(:, max_sim_DFR_idx), rest_labels(:,47)];

%% calculate similarity between representative rest and DFR 

sub1 = max_sim_DFR_idx; 
sub2 = 47; 
% in rest, there were multiple that were most similar, so choosing subject
% 47, which ended up being the same partition as subject 113) 

% reset values
M1 = 0;
M2 = 0;
w = 0;

% create contingency table
cont_DFR_rest = zeros(2,2);

for item = 1:52

    % create contingency table
    if (DFR_labels(item,sub1) == 1) && (rest_labels(item,sub2) == 1)
        cont_DFR_rest(1,1) = cont_DFR_rest(1,1) + 1;
    elseif (DFR_labels(item,sub1) == 1) && (rest_labels(item,sub2) == 2)
        cont_DFR_rest(1,2) = cont_DFR_rest(1,2) +1;
    elseif (DFR_labels(item,sub1) == 2) && (rest_labels(item,sub2) == 1)
        cont_DFR_rest(2,1) = cont_DFR_rest(2,1)+1;
    elseif (DFR_labels(item,sub1) == 2) && (rest_labels(item,sub2) == 2)
        cont_DFR_rest(2,2) = cont_DFR_rest(2,2) +1;
    end

end

% count how many pairs were labeled the same
for pair1 = 1:51
    for pair2 = (pair1+1):52
        if DFR_labels(pair1,sub1) == DFR_labels(pair2,sub1)
            M1 = M1+1;
        end
        if rest_labels(pair1,sub2) == rest_labels(pair2,sub2)
            M2 = M2+1;
        end

        if (DFR_labels(pair1,sub1) == DFR_labels(pair2,sub1)) == ( rest_labels(pair1,sub2) == rest_labels(pair2,sub2) )
            w = w+1;
        end

    end
end

% calculate rand z score
a1 = cont_DFR_rest(1,1) + cont_DFR_rest(1,2);
a2 = cont_DFR_rest(2,1) + cont_DFR_rest(2,2);
b1 = cont_DFR_rest(1,1) + cont_DFR_rest(2,1);
b2 = cont_DFR_rest(1,2)+ cont_DFR_rest(2,2);

temp_m1 = (4*M1 - (2*M))^2;
temp_m2 = (4*M2 - (2*M))^2;

c1 = (n*(n^2 - 3*n -2)) - (8*(n+1)*M1) + (4*(a1^3 + a2^3));
c2 =  n*(n^2 - 3*n -2) - 8*(n+1)*M2 + 4*(b1^3 + b2^3);

sigma_w_sq = (M/16) - (temp_m1*temp_m2)/(256*(M^2)) + ...
    ((c1*c2)/(16*n*(n-1)*(n-2))) + ...
    ((temp_m1 - (4*c1) - (4*M))*(temp_m2 - (4*c2) - (4*M)))/ ...
    (64*n*(n-1)*(n-2)*(n-3));

rand_index_DFR_rest = (w - M1*M2/M)/sqrt(sigma_w_sq);






