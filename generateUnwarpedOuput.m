function [output_image] = generateUnwarpedOuput(inliers_corr, image_width, image_height, imagel)
xl = inliers_corr(:,4);
xr = inliers_corr(:,2);
min_xl = min(xl);
max_xl = max(xl);

min_xr = min(xr);
max_xr = max(xr);
imageLisTop = false;
imageLisLeft = false;

if (min_xl > min_xr) 
   fprintf("imagel is on the left, before imager\n\n");
   x = image_width + (image_width - max_xr);
   imageLisLeft = true;
else
   fprintf("imagel is on the right, after imager\n\n");
   x = image_width + (image_width - max_xl);
end


yl = inliers_corr(:,3);
yr = inliers_corr(:,1);
min_yl = min(yl);
max_yl = max(yl);

min_yr = min(yr);
max_yr = max(yr);

if (min_yl > min_yr) 
   fprintf("imagel is on the top, before imager\n\n");
   y = image_height + (image_height - max_yr);
   imageLisTop = true;
else
   fprintf("imagel is on the bottom, after imager\n\n");
   y = image_height + (image_height - max_yl);
end

%%
output_image = zeros(y,x);

% Fill in output image using unwarped imagel
if (imageLisTop && imageLisLeft) % imagel is top left
    output_image(1:image_height, 1:image_width) = imagel;
elseif (imageLisTop && ~imageLisLeft) % image l is top right
    output_image(1:image_height,x-image_width+1:x) = imagel;
elseif (~imageLisTop && imageLisLeft) % image l is bottomleft
    output_image(y-image_height+1:y,1:image_width) = imagel;
else % image L is on bottom right
    output_image(y-image_height+1:y,x-image_width+1:x) = imagel;
end
            

end