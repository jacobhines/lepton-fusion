close all;
run('setupDirectories')

%% set fusion parameters
dataset = 'Stanford';
imgIdxs = [1, 7, 12, 16, 18, 21, 22, 30, 32, 39, 45, 46, 49, 50, 57, 62];
imgIdxs = imgIdxs([1, 3, 4, 7, 8, 14, 16]);

thrScale = 1;
visScale = 'same'; %numerical factor or 'same' to match thermal image size

showMontage = true;
showMetrics = true;
printResults = false;

%% load fusion variables

% check if we have already loaded necessary images
if ~exist('data', 'var')
    loadDataset = true;
elseif ~(strcmp(dataset, data.dataset) && isequal(imgIdxs, data.imgIdx))
    loadDataset = true;
else
    loadDataset = false;
end

if loadDataset
    % load images from dataset
    if strcmp(dataset, 'OSU')
        [thrCell, visCell, ~] = loadOSU(imgIdxs);
    elseif strcmp(dataset, 'Stanford')
        [thrCell, visCell, ~] = loadStanford(imgIdxs, 'Registered', true);
    end
end

if strcmp(visScale, 'same')
    visScale = size(thrCell{1});
end

% set fusion function
fuseFunct = @(thr, vis, cmap) fuseYCbCr(thr, vis, cmap);
fusionParam = ["jet"];
fusionParamName = 'Colormap';
fusionMethod = 'YCbCR';

% initialize data structure
clear data
data.dataset = dataset;
data.imgIdx = imgIdxs;
data.fusionParam = fusionParam;
data.fusionParamName = fusionParamName;
data.fusionMethod = fusionMethod;

% initialize fusion container
nimg = length(imgIdxs);
nparam = length(fusionParam);
data.fusion = cell(nimg,nparam);


%% image fusion

for imgIdxs = 1:nimg
    disp(['Fusing image ', num2str(imgIdxs)])
    
    % pull thermal and visible image
    thrGT = thrCell{imgIdxs};
    vis = visCell{imgIdxs};

    % resize images
    thr = imresize(thrGT, thrScale);
    vis = imresize(vis, visScale);

    for paramIdx = 1:nparam
        
        param = fusionParam(paramIdx);

        % fuse the images
        output = fuseFunct(thr, vis, param);

        % store output
        data.fusion{imgIdxs,paramIdx} = output;
    end

end

%% show results

if showMontage
    figure(1)
    composite = montage(data.fusion', 'Size', size(data.fusion), 'BorderSize', [1 1], 'BackgroundColor', 'white');
    composite = composite.CData;
end

if printResults
    % prepare filepath for saving results
    folder = 'fusion\figures';
    filename = 'composite_ycbcr';
    if ~isfolder(folder)
        mkdir(folder);
    end
    printEMF(composite, filename, 'Folder', folder)
end