% Inputs
% Image (grayscale Matrix)
% Nx2 matrix of corner features
% size of template neighborhood
% Output: Template

function template = get_template_from_corners(image, cornerFeatures, template_neighborhood)

    [iheight, iwidth] = size(image);
    % don't include points too close to the edges
    cornerFeatures(cornerFeatures(:,1) < template_neighborhood,:)=[];
    cornerFeatures(cornerFeatures(:,2) < template_neighborhood,:)=[];
    cornerFeatures(cornerFeatures(:,1) > iheight-template_neighborhood,:)=[];
    cornerFeatures(cornerFeatures(:,2) > iwidth-template_neighborhood,:)=[];
    
    % width of template
    d = floor(template_neighborhood/2);
    [iheight,iwidth,~] = size(image);
    
    % create the template for each point
    template = cell(height(cornerFeatures),2);
    
    % template is a matrix of image intensities of M x M 
    % (where M = template_neighborhood)
    for i = 1:height(cornerFeatures)
        template{i,1} = image(cornerFeatures(i,1)-d:cornerFeatures(i,1)+d,cornerFeatures(i,2)-d:cornerFeatures(i,2)+d,1);
        template{i,2} = cornerFeatures(i,1:2);
    
    end

end