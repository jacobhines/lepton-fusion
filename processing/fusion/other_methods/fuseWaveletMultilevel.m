%% setup code

close all; clear all;
home = 'C:\Users\Jacob\Google Drive\Imaging Course Project\Code\Image Fusion';
cd(home)
addpath(genpath(home))

% select dataset

% folder = 'C:\Users\Jacob\Stanford Drive\Thermal Datasets\Natural Scenes Manchester\scene7';
% [thr_orig, vis] = loadManchester(folder);

folder = 'H:\Stanford Drive\Thermal Datasets\OSU Color and Thermal Database\';
% folder = 'C:\Users\Jacob\Stanford Drive\Thermal Datasets\OSU Color and Thermal Database\';
[thr_orig, vis, rgb] = loadOSU([folder, 'thermal'], [folder, 'visible'], 1);

% downsample lwir image
scale = 0.25;
thr = imresize(thr_orig, scale);

%% wavelet transform method

% number of levels to perform wavelet transform
n = floor(log2(min(size(vis)./size(thr))));

lpfunct = @(img) waveletFunct(img, n);
gfunct = @(thr_tilde, vis_lp) 1;
% gfunct = @(thr_tilde, vis_lp) thr_tilde./vis_lp;

fusion = MRA(thr, vis, gfunct, lpfunct);

%% analysis

thr_tilde = imresize(thr, size(thr_orig));

psnr_reference = psnr(thr_tilde, thr_orig);
ssim_reference = ssim(thr_tilde, thr_orig);
qnr_reference = getQNR(thr, vis, lpfunct(vis), thr_tilde);

psnr_wavelet = psnr(fusion, thr_orig);
ssim_wavelet = ssim(fusion, thr_orig);
qnr_wavelet = getQNR(thr, vis, lpfunct(vis), fusion);




%% show results
figure(1)
montage({vis, thr_orig, thr, fusion}, 'Size', [2 2])

function img_lp = waveletFunct(img, n)

    wname = 'bior3.3'; %dmey, bior3.3 work well
    mode = 'per';
    
    img_orig = img;

    cA = cell(1, n);
    cH = cell(1, n);
    cV = cell(1, n);
    cD = cell(1, n);

    for ii = 1:n
        [cA{ii},cH{ii},cV{ii},cD{ii}] = dwt2(img,wname,'mode',mode);
        img = cA{ii};
    end

    cA = flip(cA);
    cH = flip(cH);
    cV = flip(cV);
    cD = flip(cD);

    img = 0.*img;

    for ii = 1:n
        img = imresize(img, size(cA{ii}));
        img = idwt2(img,cH{ii},cV{ii},cD{ii},wname, 'mode', mode);
    end

    img_lp = img_orig - imresize(img, size(img_orig));
    
end