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

%% bilateral filter

n_smth = 40;
n_sigma = 40;

smoothing = 10.^linspace(-3,0, n_smth);
sigma = linspace(0.01,1,n_sigma);

psnr_arr = zeros(n_smth, n_sigma);
q_arr = zeros(n_smth, n_sigma);
qnr_arr = zeros(n_smth, n_sigma);
fusion = cell(n_smth, n_sigma);

% define MRA functions
gfunct = @(thr_tilde, vis_lp) 1;
% gfunct = @(thr_tilde, vis_lp) thr_tilde./vis_lp;
lpfunct = @(vis, smoothing, sigma) imbilatfilt(vis, smoothing, sigma);


for ii = 1:n_smth
    for jj = 1:n_sigma

        % get temporary lp function
        lpfunct_temp = @(vis) lpfunct(vis, smoothing(ii), sigma(jj));

        % run MRA fusion
        out = MRA(thr, vis, gfunct, lpfunct_temp);

        psnr_arr(ii,jj) = getPSNR(out, thr_orig);
        q_arr(ii,jj) = getQ(out, thr_orig);
        qnr_arr(ii,jj) = getQNR(thr, vis, lpfunct_temp(vis), out);
    
        fusion{ii,jj} = out;
    end
    
    disp(ii)
end

thr_tilde = imresize(thr, size(thr_orig));
psnr_orig = getPSNR(thr_tilde, thr_orig);
q_orig = getQ(thr_tilde, thr_orig);
lpfunct_temp = @(vis) lpfunct(vis, smoothing(1), sigma(1));
qnr_orig = getQNR(thr, vis, lpfunct_temp(vis), thr_tilde);

psnr_arr = psnr_arr ./ psnr_orig;
q_arr = q_arr ./ q_orig;
qnr_arr = qnr_arr ./ qnr_orig;

[~, I_psnr] = max(psnr_arr(:));
[~, I_q] = max(q_arr(:));
[~, I_qnr] = max(qnr_arr(:));

figure(1)
imagesc('XData', sigma, 'YData', smoothing, 'CData', qnr_arr)
title(['QNR_0 = ', num2str(qnr_orig)])
setAxis()
ax = gca;
ax.XLim = ([min(sigma) max(sigma)]);
ax.YLim = ([min(smoothing) max(smoothing)]);
title(['QNR_0 = ' num2str(round(qnr_orig, 2))])
tightPlot()
print('bilat_metric', '-dsvg')

figure(2)
montage({fusion{1}, fusion{I_qnr}, fusion{end}}, 'Size', [3 1])
tightPlot()
print('bilat_output', '-dsvg')

function setAxis()
    colorbar()
    caxis([0.98 1.02])
    ax = gca;
    ax.YDir = 'normal';
    xlabel('\sigma')
    ylabel('smoothing')
end

function [I1, I2] = getMaxIndices(array)
    [M1, I1] = max(array);
    [~, I2] = max(M1);
    I1 = I1(I2);
end
