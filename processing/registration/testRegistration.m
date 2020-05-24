close all
run('setupDirectories')

% this script performs image registration for the Stanford thermal dataset

datasetFolder = 'datasets\Stanford\';

imgIdxs = 1:62;
nfiles = length(imgIdxs);

% load dataset if not already loaded
if ~exist('thrCells','var')
    disp('Loading dataset images.')
    
    [thrCells, visCells, ~] = loadStanford(1:nfiles);
end

% set edge methods
% methods = {'approxcanny', 'Canny', 'log', 'Prewitt', 'Roberts', 'Sobel', 'zerocross'};
methods = {'Canny'};

for idx = 1:length(methods)

    % initialize containers
    t = zeros(1, nfiles);
    shifts = zeros(nfiles, 2);
    cvec = zeros(1,nfiles);
    edgeMethod = methods{idx};
    
    disp(edgeMethod)
    
    % iterate over dataset
    for ii = imgIdxs
        thr = thrCells{ii};
        vis = visCells{ii};
        
        tic
        % register image
        [thr_registered, data] = registerImage(thr, vis, edgeMethod);
        
        % record registration data
        t(ii) = toc;
        shifts(ii,:) = data.shift;
        cvec(ii) = data.cOpt;
        
        % save the registered image
        filename = fullfile(datasetFolder, 'registered', num2str(ii, '%04.f'));
        imwrite(thr_registered, [filename, '.bmp'])
        
        % save other images
        foldername = fullfile('registration\registered_images', edgeMethod);
        
        filename = [num2str(ii), '_ethr'];
        printEMF(data.eimg_registered, foldername, filename)
    
        filename = [num2str(ii), '_evis'];
        printEMF(data.eref_resized, foldername, filename)
        
        I = imfuse(data.eimg_registered, data.eref_resized);
        filename = [num2str(ii), '_efused'];
        printEMF(I, foldername, filename)
        
        I = imfuse(data.ref_resized, thr_registered);
        filename = num2str(ii);
        printEMF(I, foldername, filename)
    end

    % save statistics for each method
    s.t = t;
    s.shifts = shifts;
    s.cvec = cvec;
    s.edgeMethod = edgeMethod;

    save(['registration\stats\', edgeMethod], 's');
end