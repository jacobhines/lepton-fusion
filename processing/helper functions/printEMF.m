function printEMF(img, filename, varargin)
    % a helper printing function

    folder = parseInputVar('Folder', '', varargin{:});

    figure(1)
    imshow(img)

    set(gca,'units','pixels') % set the axes units to pixels
    x = get(gca,'position'); % get the position of the axes
    set(gcf,'units','pixels') % set the figure units to pixels
    y = get(gcf,'position'); % get the figure position
    set(gcf,'position',[y(1) y(2) x(3) x(4)])% set the position of the figure to the length and width of the axes
    set(gca,'units','normalized','position',[0 0 1 1]) % set the axes

    fullFilepath = fullfile(folder, [filename, '.emf']);
    saveas(gcf, fullFilepath)

end