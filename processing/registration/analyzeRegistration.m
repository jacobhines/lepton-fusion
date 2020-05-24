close all;
run('setupDirectories')

% this script analyzes the results of different edge detection methods for
% image registration

% methods = {'approxcanny', 'Canny', 'log', 'Prewitt', 'Roberts', 'Sobel', 'zerocross'};
methods = {'Canny'};
nmethods = length(methods);

% allowed shift box
xc = 5;
yc = 7;
xw = 5;
yw = 5;
pos = [xc - xw, yc - yw, 2*xw, 2*yw];

shiftsx = zeros(62, nmethods);
shiftsy = zeros(62, nmethods);


for idx = 1:nmethods
    edgeMethod = methods{idx};
    load(['registration\stats\', edgeMethod])
    
    shifts = s.shifts;
    shiftsx(:,idx) = shifts(:,1);
    shiftsy(:,idx) = shifts(:,2);

    success_h = abs(shifts(:,1) - xc) <= xw;
    success_v = abs(shifts(:,2) - yc) <= yw;
    s.success = and(success_h, success_v);
    s.successRate = nnz(s.success)/length(s.success);

    save(['registration\stats\', edgeMethod], 's');
end

figure(1)
hold all

edges = min(shifts(:)) : max(shifts(:));
histogram(shiftsx, edges)
histogram(shiftsy, edges)
grid on
xlabel('shift (px)')
ylabel('count')
legend({'x shift', 'y shift'})
title('Canny Shift Distribution')

print('registration\figures\shifts_allMethods', '-dsvg')