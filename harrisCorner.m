function sparse_corners = harrisCorner(image, window_size, k, R_threshold)
% Input is images, output is vector of pixel locations corresponding to
% corner
format bank;

% Initialize vector
corner_features(1,:) = [0,0];

prewitt_x = zeros(window_size,3);
prewitt_x(:,1) = -1;
prewitt_x(:,3) = 1;

prewitt_y = zeros(3,window_size);
prewitt_y(1,:) = -1;
prewitt_y(3,:) = 1;

% Compute Ix, Iy Gradient images
Ix = imfilter(image, prewitt_x);
Iy = imfilter(image, prewitt_y);

Ix2 = Ix .^ Ix;
Iy2 = Iy .^ Iy;
Ixy = Ix .* Iy;

gaussian = fspecial('gaussian', window_size);
Ix2_sums = imfilter(Ix2, gaussian);
Iy2_sums = imfilter(Iy2, gaussian);
Ixy_sums = imfilter(Ixy, gaussian);

count = 1;
% Compute C Matrix and R for each pixel
for i = 1:size(image,1)
    for j = 1:size(image, 2)
        M(1,1) = Ix2_sums(i,j);
        M(1,2) = Ixy_sums(i,j);
        M(2,1) = Ixy_sums(i,j);
        M(2,2) = Iy2_sums(i,j);
        [~,S,~] = svd(M);
        
        R = det(S) - k*trace(S);
        R_mat(i,j) = R_threshold;
        if R > R_threshold
            corner_features(count, 1:2) = [i, j]; % coordinates of corner
            corner_features(count,3) = R;         % corresponding R score
            count = count + 1;
        end
    end
end

sparse_corners =  nonMaxSuppression(image, corner_features, R_mat);

end