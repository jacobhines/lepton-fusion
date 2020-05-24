function [thr, vis, rgb] = loadStanford(idxs, varargin)

    % given the image indices from the Stanford dataset, this function
    % returns the associated images

    registered = parseInputVar('Registered', false, varargin{:});
    asMatrix = parseInputVar('AsMatrix', false, varargin{:});

    nimages = length(idxs);
    thr = cell(1, nimages);
    vis = cell(1, nimages);
    rgb = cell(1, nimages);

    filepath = mfilename('fullpath');
    [folder, ~, ~] = fileparts(filepath);
    
    if registered
        thrfolder = fullfile(folder, 'Stanford\registered','*.bmp');
    else
        thrfolder = fullfile(folder, 'Stanford\thermal','*.jpg');
    end
    
    filesThr = dir(thrfolder);
    filesVis = dir(fullfile(folder, 'Stanford\visible\*.jpg'));
    
    for ii = 1:nimages
        idx = idxs(ii);
        
        imgpath = fullfile(filesThr(idx).folder, filesThr(idx).name);
        imageThr = im2double(imread(imgpath));
        if length(size(imageThr)) == 3
            imageThr = rgb2gray(imageThr);
        end


        imgpath = fullfile(filesVis(idx).folder, filesVis(idx).name);
        imageRGB = im2double(imread(imgpath));
        
        % crop images if registered
        if registered
            [imageThr, imageRGB] = cropRegisteredImages(imageThr, imageRGB);
        end
        
        imageVis = rgb2gray(imageRGB);
        
        thr{ii} = imageThr;
        vis{ii} = imageVis;
        rgb{ii} = imageRGB;
    end
    
    if asMatrix && (nimages == 1)
        thr = thr{1};
        vis = vis{1};
        rgb = rgb{1};
    end
end

function [thr, varargout] = cropRegisteredImages(thr, varargin)

    % mask off the black parts of the registered thermal image
    thrMask = (thr>0);
    stats = regionprops(thrMask>0, 'BoundingBox');
    box = stats.BoundingBox;
    
    % crop the thermal image to remove black area surrounding it
    thr = imcrop(thr, box);
    thr = thr(1:end-1, 1:end-1);

    % crop other input images based on thermal mask
    nimgs = length(varargin);
    varargout = cell(1, nimgs);
    
    for ii = 1:nimgs
        img = varargin{ii};
        imgMask = imresize(thrMask, size(img(:,:,1)));
        stats = regionprops(imgMask>0, 'BoundingBox');
        img = imcrop(img, stats.BoundingBox);
        varargout{ii} = img(1:end-1, 1:end-1, :);
    end
    
end