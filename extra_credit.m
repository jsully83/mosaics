% Extra Credit
close all; clc;clear;
Folder = 'DanaOffice';
office = imageDatastore(fullfile(pwd,Folder));
image_dana = double(mat2gray(rgb2gray(readimage(office,1))));
image_dog = double(mat2gray(rgb2gray(imread('dog_surfboard.jpg')))); 

% collect mouse clicks
figure(1);
imshow(image_dana);
fprintf("select the corners of the computer screen in the order top left, top right, bottom right, bottom left");
[x_dana,y_dana] = ginput(4);

figure(2);
imshow(image_dog);
fprintf("select the corners of the frame around the dog that you want to project on the computer in the order top left, top right, bottom right, bottom left");
[x_dog,y_dog] = ginput(4);

correlations = [x_dog, y_dog, x_dana, y_dana];


H = get_homography(correlations); % dog 2 dana

% find the corners of the warped image (dog) in world coordinates (dana)
ztopleft = floor(hom2cart((H * [correlations(1,1);correlations(1,2);1])'));
ztopright = floor(hom2cart((H * [correlations(2,1);correlations(2,2);1])'));
zbottomleft = floor(hom2cart((H * [correlations(4,1);correlations(4,2);1])'));
zbottomright = floor(hom2cart((H * [correlations(3,1);correlations(3,2);1])'));

yWarpOffset = floor(H(1,3))-1;
xWarpOffset = floor(H(2,3))-1;

% Coordinates of the dog frame corners in the dana coordinates
xMin = floor(abs(min(min(ztopleft(1),zbottomleft(1)))));
xMax = floor(abs(max(max(ztopright(1), zbottomright(1)))));
yMin = floor(abs(min(min(ztopleft(2),ztopright(2)))));
yMax = floor(abs(max(max(zbottomleft(2), zbottomright(2)))));

[xi, yi] = meshgrid(1:size(image_dog,2),1:size(image_dog,1));
h = inv(H); %backwards warping
xx = (h(1,1)*xi+h(1,2)*yi+h(1,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3)); 
yy = (h(2,1)*xi+h(2,2)*yi+h(2,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3)); 
warped_image = interp2(double(image_dog),xx,yy); 
figure;imshow(warped_image);
warped_mask = (warped_image > 0)*1;

padded_dana = zeros(size(warped_mask));
for i = 1:size(image_dana,1)
    for j = 1:size(image_dana,2)
        padded_dana(i,j) = image_dana(i,j);
    end
end
imshow(padded_dana);   
% warped_mask(warped_mask > 0) = image_dog;
imshow(warped_mask);
for i = 1:size(warped_mask,1)
    for j = 1:size(warped_mask,2)
        if warped_mask(i,j) > 0
            padded_dana(i,j) = warped_image(i,j);
        end
    end
end

mask = warped_mask;
mask = (mask>1)*1;
figure(3);
imshow(padded_dana);
title('warped image')