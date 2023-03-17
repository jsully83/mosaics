% This function computes the number of inliers given a list of
% image correspondences in the format Nx4, where N is the number of 
% Correspondences ant each column is in the format [x1 y1 x1' y1']. 
% The given 3x3 Homography Matrix is also an input
% Outputs are the number of inliers and the index vector, which is the
% index of the correspondence that is an inlier for the given homography
% matrix.

function [num_inliers, ind] = RANSAC(correspondences, homography_matrix, max_error)

n = size(correspondences,1);
num_inliers = 0;
ind = {};
for i = 1:n
 
 H = homography_matrix; 
 pt1 = [correspondences(i,1) correspondences(i,2) 1]';
 pt2_projected = H * pt1;
 pt2_projected = pt2_projected ./ pt2_projected(3);
 pt2 = [correspondences(i,3) correspondences(i,4) 1]';
 error = norm(pt2_projected - pt2);
 if (error <= max_error)
     num_inliers = num_inliers+1;
     ind = [ind; i];
 end

end

end







