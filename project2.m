% Project 2: Image Mosaicing
clc;clear; close all;

%% Tuning Parameters
scale_factor = 1; % must be integer; ie: if scale factor = 2, uses every other pixel

% Harris Params
harris_window_size = 3;
R_threshold = 1.5;
k = 0.04;

%% Read in Images (Part i)
% office = load_images('DanaOffice', 340, 512, scale_factor);
Folder = 'DanaOffice';
office = imageDatastore(fullfile(pwd,Folder));
imager = double(mat2gray(rgb2gray(readimage(office,1)))); % Panorama starts right and moves left
imagel = double(mat2gray(rgb2gray(readimage(office,2))));



[iheight,iwidth] = size(imager);
%% Harris Corner Detector (part ii)

% Harris Corner Detector
% Corner features in [x y] format correponding to coordinates of a corner
% feature. Nx2 vector where N Is number of corner features
cornerFeaturesr = harrisCorner(imager,harris_window_size, k, R_threshold);
cornerFeaturesl = harrisCorner(imagel,harris_window_size, k, R_threshold);

% process takes a while so use this to limit the number of corners for testing.
% smaller tolerance = more points
% tolerance = 0.005; 
% cornerFeaturesr = uniquetol(cornerFeaturesr,tolerance,'ByRows',true); 
% cornerFeaturesl = uniquetol(cornerFeaturesl,tolerance,'ByRows',true); 
% Use the corners to create a template, which is just image patches
% sampled at the harris corners. correspondences is a 1 X N cell, 
% where N is the number of correspondences. Each cell has an MxM image
% patch centered at a corner, where M = template_neighborhood.
template_neighborhood = 21;

templater = get_template_from_corners(imager,cornerFeaturesr,template_neighborhood);
templatel = get_template_from_corners(imagel,cornerFeaturesl,template_neighborhood);

figure;

imshowpair(imagel, imager, 'montage')
axis on;
hold on;
plot(cornerFeaturesr(:,2) + size(imager,2),cornerFeaturesr(:,1), 'y.');
plot(cornerFeaturesl(:,2),cornerFeaturesl(:,1), 'y.');
%% find the corresponding corner in the next image using normalized cross

threshold = 0.75;

correspondences = norm_xcorr(templater,templatel);

testpoints = correspondences(correspondences(:,5) >= threshold,:);

% see the correspondences
fusedimage = imfuse(imagel, imager, 'montage'); 

figure;

imshowpair(imagel, imager, 'montage')

axis on;
hold on;

plot(cornerFeaturesr(:,2)+512,cornerFeaturesr(:,1), 'y.');
plot(cornerFeaturesl(:,2),cornerFeaturesl(:,1), 'y.');
plot(testpoints(:,2)+512,testpoints(:,1), 'r.','MarkerSize',1, 'LineWidth',1);
plot(testpoints(:,4),testpoints(:,3), 'r.','MarkerSize',1, 'LineWidth',1);


for i = 1:height(testpoints)
        plot([testpoints(i,4),testpoints(i,2)+512],[testpoints(i,3),testpoints(i,1)]);
end
%% Part iv - Estimate Homography with RANSAC and least squares using inliers


max_error = 50;
num_correspondences = height(testpoints);
tries = 1000;
ind = cell(tries,1);
% RANSAC
for i = 1:tries
    random_idx = randsample(num_correspondences, 4);
    min_corr = testpoints(random_idx,1:4);
    
    temp_h = get_homography(min_corr);
    
    [num_inliers(i),ind{i}] = RANSAC(testpoints,temp_h, max_error);
end
[max_inliers, I] = max(num_inliers);
inliers = cell2mat(ind{I});
inliers_corr = testpoints(inliers, :);
correspondences = inliers_corr;
% H = get_homography(correspondences);
fprintf("max number of inliers is %f\n", max_inliers)

%close all;
figure;
imshowpair(imagel, imager, 'montage')
axis on;
hold on;

plot(inliers_corr(:,2) + size(imagel,2) ,inliers_corr(:,1), 'r.', 'MarkerSize', 10, 'LineWidth',2);
plot(inliers_corr(:,4),inliers_corr(:,3), 'r.', 'MarkerSize', 10, 'LineWidth',2)

for i = 1:height(inliers_corr)
        plot([inliers_corr(i,4),inliers_corr(i,2) + size(imagel,2)],[inliers_corr(i,3),inliers_corr(i,1)]);
end

 title("Correspondences that are used to estimate Homography");
%%

fprintf("max number of inliers is %f\n", max_inliers)
figure;
imshowpair(imagel, imager, 'montage')
axis on;
hold on;

% get homography and it's inverse
H = get_homography(correspondences);


h = inv(H); %backwards warping

% find the corners of the warped image in world coordinates
ztopleft = floor(hom2cart((H * [1;1;1])'));
ztopright = floor(hom2cart((H * [1;size(imager,2);1])'));
zbottomleft = floor(hom2cart((H * [size(imager,1);1;1])'));
zbottomright = floor(hom2cart((H * [size(imager,1);size(imager,2);1])'));

yWarpOffset = floor(H(1,3))-1;
xWarpOffset = floor(H(2,3))-1;

xMin = abs(min(min(ztopleft(1),zbottomleft(1))));
xMax = abs(max(max(ztopright(1), zbottomright(2))));
yMin = abs(min(min(ztopleft(2),ztopright(2))));
yMax = abs(max(max(zbottomleft(2), zbottomright(2))));

yMosaicOffset = (yMax - size(imagel,1))/2;

%create a blank canvas with the world coordinate system 

% we want the max to be the maximum world coordinate and the min to be the
% minimum world coordinates minus the offset of the homography.  y is
% centered in the mosaic
[xi, yi] = meshgrid(xMin-xWarpOffset:xMax,yMin-yWarpOffset-yMosaicOffset:yMax);
% [xi, yi] = meshgrid(-50:xMax+200,-50:yMax+200)
xx = (h(1,1)*xi+h(1,2)*yi+h(1,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3)); 
yy = (h(2,1)*xi+h(2,2)*yi+h(2,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3)); 

% backwards warp image1 
warped_image = interp2(double(imager), xx, yy);

%mask the overlapping region
warped_mask = (warped_image > 0)*1;
center_mask = zeros(size(warped_image));
center_mask(yMosaicOffset:yMax-yMosaicOffset-1,1:size(imagel,2)) = ones(size(imagel));


mask = warped_mask+center_mask;
mask = (mask>1)*1;

% blend the pixels in the overlapping region
canvas1 = zeros(size(warped_image));
canvas2 = zeros(size(warped_image));
mosaic = zeros(size(warped_image));
canvas1(:) = warped_image;
canvas2(yMosaicOffset:yMax-yMosaicOffset-1,1:size(imagel,2)) = imagel;
canvas1(isnan(canvas1))=0;
canvas2(isnan(canvas2))=0;

for i = 1:size(mask,1)
    for j = 1:size(mask,2)
        if mask(i,j) > 0
            mosaic(i,j) = (canvas1(i,j) + canvas2(i,j)) / 2;
        else
            mosaic(i,j) = canvas1(i,j) + canvas2(i,j);
        end
    end
end

close all;
figure(4);
imshow(mosaic)
hold on;
axis on;
plot(xWarpOffset, yWarpOffset+yMosaicOffset, 'r.')


