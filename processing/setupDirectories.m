% Run this file first before doing anything else. All the matlab code in
% \thermal-camera\processing is run with paths referenced to \thermal-camera\processing

filepath = mfilename('fullpath');
[folder, ~, ~] = fileparts(filepath);
cd(folder)
addpath(genpath(folder))

clear filepath folder