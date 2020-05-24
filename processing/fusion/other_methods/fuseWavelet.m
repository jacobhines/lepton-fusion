%% load files

addpath(genpath('C:\Users\Jacob\Google Drive\Imaging Course Project\Code\Image Fusion'))
close all; clear all;

% folder = 'H:\Stanford Drive\Thermal Datasets\Natural Scenes Manchester\scene7';
% [lwir_orig, vis] = loadManchester(folder);

folder = 'H:\Stanford Drive\Thermal Datasets\OSU Color and Thermal Database\';
% folder = 'C:\Users\Jacob\Stanford Drive\Thermal Datasets\OSU Color and Thermal Database\';

[lwir_orig, vis, rgb] = loadOSU([folder, 'thermal'], [folder, 'visible'], 1);

% downsample lwir image
scale = 0.25;
lwir = imresize(lwir_orig, scale);

%% wavelet transform method

wname = 'rbio1.1'; %haar, fk4, bior1.1, and rbio1.1 work well
mode = 'zpd';

[cA,cH,cV,cD] = dwt2(vis,wname,'mode',mode);

lwir_cA = imresize(lwir, size(cA));

lwir_cA = rescale(lwir_cA, min(cA(:)), max(cA(:)));

fusion = idwt2(lwir_cA,cH,cV,cD,wname);


%% show results
figure(1)
montage({vis, lwir, fusion}, 'Size', [1 3])

figure(2)
montage({cA, cH, cV, cD})