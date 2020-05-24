close all;
clear baseline metrics
run('setupDirectories')

%% set fusion parameters
dataset = 'Stanford';
imgIdxs = [1, 7, 12, 16, 18, 21, 22, 30, 32, 39, 45, 46, 49, 50, 57, 62];
imgIdxs = imgIdxs([1, 3, 4, 7, 8, 14, 16]);
fusionMethod = 'GTF';

thrScale = 0.5;
visScale = 'same'; %numerical factor or 'same' to match thermal image size

showMontage = true;
showMetrics = true;
printMontage = false;

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
    disp('Loading dataset...')
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

% set fusion function by method
if strcmp(fusionMethod, 'HPF')
%     fusionParam = 10.^linspace(-1,3,100);
    fusionParam = [1];
    fusionParamName = '\alpha';
    fuseFunct = @(thr, vis, alpha) fuseHPF(thr, vis, alpha);
elseif strcmp(fusionMethod, 'GTF') 
    numItersADMM = 20;
%     fusionParam = 10.^linspace(-4,1,100);
    fusionParam = 0.1;
    fusionParamName = '\lambda';
    fuseFunct = @(thr, vis, lambda) fuseGTF(thr, vis, lambda, numItersADMM);
end

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

    % initialize struct for calculating fusion metrics
    mParams.thr = thr;
    mParams.vis = vis;
    mParams.thrGT = thrGT;
    mParams.thrScale = thrScale;
    
    % calculate baseline metric for image wihtout fusion
    mParams.fusion = imresize(mParams.thr, size(mParams.vis));
    baseline(imgIdxs) = getMetrics(mParams);

    for paramIdx = 1:nparam        
        param = fusionParam(paramIdx);

        % fuse the images
        output = fuseFunct(thr, vis, param);

        % store output
        data.fusion{imgIdxs,paramIdx} = output;
        
        % calculate evaluation metrics
        mParams.fusion = output;
        metrics(imgIdxs, paramIdx) = getMetrics(mParams);
    end

end

%% analysis

% normalize metrics for plotting
fields = string(fieldnames(metrics));
metricsCell = struct2cell(metrics);
baselineCell = struct2cell(baseline);

metrics = struct();
baseline = struct();

for ii = 1:length(fields)
    baseline = setfield(baseline, fields(ii), ...
                          squeeze(cell2mat(baselineCell(ii, :, :))));
    
    temp = squeeze(cell2mat(metricsCell(ii, :, :)));
    temp = temp./(getfield(baseline, fields(ii)));
    metrics = setfield(metrics, fields(ii), temp);
end

%% show results

if showMontage
    figure(1)
    composite = montage(data.fusion', 'Size', size(data.fusion), 'BorderSize', [1 1], 'BackgroundColor', 'white');
%     composite = montage(data.fusion', 'Size', [NaN 2], 'BorderSize', [2 2], 'BackgroundColor', 'white');
    composite = composite.CData;
end

if printMontage
    % prepare filepath for saving results
    folder = 'fusion\figures';
    filename = ['composite_', data.fusionMethod];
    if ~isfolder(folder)
        mkdir(folder);
    end
    printEMF(composite, filename, 'Folder', folder)
end


if showMetrics
    figure(2)   
    if (nimg == 1)

        for ii = 1:length(fields)
            semilogx(data.fusionParam, getfield(metrics, fields(ii)), 'LineWidth', 2)
            hold all
        end
        grid on
        ylim([0.0 1.4])
        xlabel(fusionParamName)
        ylabel('Normalized Metric')
        legend(fields, 'Location', 'southwest')
        title(data.fusionMethod)

    else
        for ii = 1:length(fields)
            temp = getfield(metrics, fields(ii));
            plot(1:nimg, max(temp,[],2), 'LineWidth', 2)
            hold all
        end
%         set(gca,'yscale','log')
        grid on
        ylim([0 1.6])
        xlim([0 nimg])
        xlabel('Image Number')
        ylabel('Normalized Metric')
%         legend(fields, 'Location', 'southeast')
        title([data.fusionMethod, ', ' data.fusionParamName, ' = ', num2str(data.fusionParam)])
    end
end