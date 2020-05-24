close all; clear all;

% folder = 'H:\Stanford Drive\Thermal Datasets\Natural Scenes Manchester\scene8';
% [lwir_orig, vis] = loadManchester(folder);

folder = 'H:\Stanford Drive\Thermal Datasets\OSU Color and Thermal Database\';
[lwir_orig, vis, rgb] = loadOSU([folder, 'thermal'], [folder, 'visible'], 1);

% downsample lwir image
scale = 0.25;
lwir = imresize(lwir_orig, scale);

% resize lwir image to match visible image
imsize = size(vis);
lwir = imresize(lwir, imsize);

% equalize visible image
vis_histeq = adapthisteq(vis, 'NumTiles', round(imsize/3));

% combine the images
fusion = rescale(lwir.*vis_histeq);

figure(1)
montage({vis, lwir, vis_histeq, fusion}, 'Size', [2 2])