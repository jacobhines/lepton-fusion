% This sample script registers a VIS+LWIR image pair and displays the fused
% result for the GTF fusion method

close all;
run('setupDirectories')

% load the first image pair from the dataset
[thr, vis] = loadStanford(7, 'AsMatrix', true);

vis = imresize(vis, size(thr));
thr = imresize(thr, 0.5);

% register the thermal image with the visible image
thr_reg = registerImage(thr, vis, 'Canny');

% fuse the registered images
lambda = 0.1;
numItersADMM = 20;
fusionGTF = fuseGTF(thr_reg, vis, lambda, numItersADMM);

% show the fused images
figure(1)

imshow(fusionGTF)