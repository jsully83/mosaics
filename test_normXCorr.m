clear;
clc;
close all;

image = imread('peppers.png');

[r,s] = size(image);
offset = 15;
sx = randi([offset+1 r-offset],1);
sy = randi([offset+1 r-offset],1);

template = image(sx-offset:sx+offset,sy-offset:sy+offset);

tic
[max_nxcc, x, y] = norm_xcorr(image, template);
toc



figure;
subplot(1,2,1)
imshow(mat2gray(template));

subplot(1,2,2)
imshow(uint8(image))
hold on; 
rectangle('position',[sy-offset sx-offset 2*offset 2*offset], 'EdgeColor','w')
plot(x,y,'w+', 'MarkerSize', 5,'LineWidth',1);

xlabel(sprintf('max cross correlation = %0.4f', max_nxcc))
