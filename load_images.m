function image_mat = load_images(namestr, height, width, scale_factor) 
    ImgFolder = dir(namestr);
    num_elements_folder = length(ImgFolder);
    num_images = length(ImgFolder)-2;
    
    image_mat = zeros(height/scale_factor,width/scale_factor,(num_images));
    
    % Read all images into a matrix
    for i = 3:num_elements_folder
        image_path = fullfile(ImgFolder(i).folder, ImgFolder(i).name); %added this because I have a mac
        rgb_image = imread(image_path);
        grey_img = im2double(im2gray(rgb_image));
        subsampled_image = grey_img(1:scale_factor:end, 1:scale_factor:end);
        image_mat(:,:,i-2) = subsampled_image;
    end

end