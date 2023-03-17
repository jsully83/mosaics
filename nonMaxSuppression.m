function sparse_corners = nonMaxSuppression(image, harris_corners, R_mat)
% Given pixel locations corresponding to harris corners, compute nonmax suppression

% Get image patches 
sparse_corners = [];
max_j = round(size(image,1));
max_i = round(size(image,2));

% Pad R_matrix to make it easier to compare R values at the borders of the
% image
R_mat = [zeros(max_j,1) R_mat zeros(max_j,1)];
R_mat = [zeros(1,max_i+2); R_mat; zeros(1,max_i+2)];

% if harris_corner_indices(count,1) == i && harris_corner_indices(count,2) == j
% 
% neighborhood_8 = [i-1, j-1; i, j-1; i+1, j-1; i-1,j; i+1,j; i-1,j+1, i,j+1;i+1,j+1];
% 
% for k = 1:7
%     if (neighborhood_8(k,1) > 0  && neighborhood_8(k,2) > 0)
%         if image(neighborhood_8(k,1), neighborhood_8(k,2)) > image(harris_corner_indices(count,1), harris_corner_indices(count,2))
%             harris_corner_indices(count,:) = [-1,-1];
%             count = count + 1;
%         end
%     end
% 
% end
    
%for each harris corner, figure out if it has the max R of its neighbors.
%If not, remove it frome list.
for idx = 1:size(harris_corners,1)
    i = harris_corners(idx,1);
    j = harris_corners(idx,2);
    R = harris_corners(idx,3);
    
    % indices for R matrix are incremented, due to padding in line 11
    ir = i+1;
    jr = j+1;

    neighborhood_8 = [ir - 1, jr - 1; 
                      ir    , jr - 1;
                      ir + 1, jr - 1;
                      ir - 1, jr    ; 
                      ir + 1, jr    ;
                      ir - 1, jr + 1; 
                      ir    , jr + 1;
                      ir + 1, jr + 1];
    suppress = false;
    for k = 1:8 % for each neighbor
        if R_mat(neighborhood_8(k,1),neighborhood_8(k,2)) > R
            suppress = true;
        end
    end

    if (~suppress)
        sparse_corners = [sparse_corners; i,j];
    end

end

% neighborhood of a pixel are (i-1,j-1)       (i, j-1)     (i+1,  j-1)
%                           (i-1, j)       (i, j)       (i+1, j)
%                           (i-1, j+1)     (i, j+1)     (i+1, j+1)

end