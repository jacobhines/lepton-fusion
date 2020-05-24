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

%% high frequency filter

n = 100;
sigma = linspace(0.01,1,n);
psnr_vec = zeros(1,n);
q_vec = zeros(1,n);
qnr_vec = zeros(1,n);
fusion = cell(1,n);

% define HPF functions

lpfunct = @(vis, s) imgaussfilt(vis, s);


for ii = 1:n

    % get temporary lp function
    lpfunct_temp = @(vis) lpfunct(vis, sigma(ii));

    % run MRA fusion
    fusion{ii} = fuseMRA(thr, vis, gfunct, lpfunct_temp);
    
    psnr_vec(ii) = getPSNR(fusion{ii}, thr_orig);
    q_vec(ii) = getQ(fusion{ii}, thr_orig);
    qnr_vec(ii) = getQNR(thr, vis, lpfunct_temp(vis), fusion{ii});
    
    disp(ii)

end

thr_tilde = imresize(thr, size(thr_orig));
psnr_orig = getPSNR(thr_tilde, thr_orig);
q_orig = getQ(thr_tilde, thr_orig);

lpfunct_temp = @(vis) lpfunct(vis, sigma(1));
qnr_orig = getQNR(thr, vis, lpfunct_temp(vis), thr_tilde);

psnr_vec = psnr_vec ./ psnr_orig;
q_vec = q_vec ./ q_orig;
qnr_vec = qnr_vec ./ qnr_orig;

[~, I_psnr] = max(psnr_vec);
[~, I_q] = max(q_vec);
[~, I_qnr] = max(qnr_vec);

figure(1)


plot(sigma, psnr_vec)
hold all
plot(sigma, q_vec)
plot(sigma, qnr_vec)
grid on

ylabel('Normalized Metric')
xlabel('\sigma_{gauss}')
ylim([0.98, 1.02])

title(['PSNR_0 = ', num2str(psnr_orig), ', Q_0 = ', num2str(q_orig), ', QNR_0 = ' num2str(qnr_orig)])

legend('PSNR', 'Q', 'QNR')

figure(2)
montage({vis, thr_orig, thr, fusion{I_psnr}, fusion{I_q}, fusion{I_qnr}}, 'Size', [2 3])
