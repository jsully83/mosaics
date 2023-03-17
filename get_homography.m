function homography = get_homography(correspondences)
    
    num_corr = height(correspondences);
    
    %{
    For >4 correspondences create a homography matrix of size 2nx9 
    %}
    
    % find the transformation and scale matricies for the set1 and set2
    % points

    [normalized_correspondences,T1, T2, S1, S2,matrix1,matrix2] = hartleys_preconditioning(correspondences);
    x1a = normalized_correspondences(:,1);
    y1a = normalized_correspondences(:,2);
    x1b = normalized_correspondences(:,3);
    y1b = normalized_correspondences(:,4);

    % find h_norm using SVD
    if num_corr >= 4 
        A = zeros(2*num_corr,9);

        % Construct A  matrix, solve for homography
        A(1:2:2*num_corr,:) = [x1a y1a ones(num_corr,1) zeros(num_corr,3) -x1a.*x1b -y1a.*x1b -x1b];
        A(2:2:2*num_corr,:) = [zeros(num_corr,3) x1a y1a ones(num_corr,1) -x1a.*y1b -y1a.*y1b -y1b];
    
    else
        disp("NEED MORE THAN 4 POINTS")
    
    end
    
    [U,D,V] = svd(A'*A,"vector");

    h_temp = U(:,end);
%     h_norm = reshape(h_temp,3,3) / h_temp(end:end);
    h_norm = reshape(h_temp,3,3);

    % denormalized to find H
    homography = inv(T2)*inv(S2)*h_norm*S1*(T1);
%     homography = matrix1 \ (h_norm * matrix1);
    homography = homography ./ homography(end:end);   

end
