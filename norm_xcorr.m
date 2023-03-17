%% Normalized Cross Correlation 
function correspondences = norm_xcorr(template1, template2)
    
    if height(template1) <= height(template2)
        A = template1;
        B = template2;
    else
        A = template2;
        B = template1;
    end
    
    score = zeros(size(A, 1),1);
    correspondences = zeros(size(A, 1), 5);
    tic
    
    for i = 1:height(A)
        
        amean = mean2(A{i,1});
        anum = A{i,1}-amean;
        adenom = sqrt(sum(anum.^2,'all'));
    
    
        for j = 1:height(B)
    
            bmean = mean2(B{j,1});
            bnum = B{j,1}-bmean;
            bdenom = sqrt(sum(bnum.^2,'all'));
    
            score(j) = sum(anum.*bnum,'all')/(adenom*bdenom);
    
            
    
    
        end
        [max_score,idx] = max(score);
        correspondences(i,:) = [A{i,2},B{idx,2},max_score];
        B(idx,:)=[];
        score=0;
    end
end


