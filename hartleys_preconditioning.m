function [normalized_correspondences,T1, T2, S1, S2,matrix1,matrix2] = hartleys_preconditioning(correspondences)
% function [normalized_correspondences,matrix1, matrix2] = hartleys_preconditioning(correspondences)
    num_correspondences = height(correspondences);
    
    tx1 = mean(correspondences(:,1));
    ty1 = mean(correspondences(:,2));
    tx2 = mean(correspondences(:,3));
    ty2 = mean(correspondences(:,4));
    
    T1 = [1 0 -tx1; 0 1 -ty1; 0 0 1];
    T2 = [1 0 -tx2; 0 1 -ty2; 0 0 1];

    temp = zeros(num_correspondences,4);
    for i = 1:num_correspondences
        temp(i,1:2) = hom2cart((T1 * cart2hom(correspondences(i,1:2))')'); 
        temp(i,3:4) = hom2cart((T2 * cart2hom(correspondences(i,3:4))')'); 
    end
    
    avg_dist1 = mean(hypot(temp(:,1),temp(:,2)));
    avg_dist2 = mean(hypot(temp(:,3),temp(:,4)));

    S1 = [sqrt(2)/avg_dist1 0 0; 0 sqrt(2)/avg_dist1 0; 0 0 1];
    S2 = [sqrt(2)/avg_dist2 0 0; 0 sqrt(2)/avg_dist2 0; 0 0 1];
    
    normalized_correspondences = zeros(num_correspondences,4);
    for i = 1:num_correspondences
        normalized_correspondences(i,1:2) = hom2cart((S1 * cart2hom(temp(i,1:2))')');
        normalized_correspondences(i,3:4) = hom2cart((S2 * cart2hom(temp(i,3:4))')');
    
    end

    matrix1 = S1 + [zeros(3,2) [tx1/100; ty1/100; 0]];
    matrix2 = S2 + [zeros(3,2) [tx2/100; ty2/100; 0]];

end
