function fusion = fuseYCbCr(img_chrom, img_lum, cmap)

    % set colormap 
    if isa(cmap, 'string')
        cmap = colormap(cmap);
    end

    % extract the luminance
    if size(img_lum, 3) == 3
        img_lum = rgb2ycbcr(img_lum);
        img_lum = img_lum(:,:,1);
    end
    
    img_chrom = imresize(img_chrom, size(img_lum)); 

    % extract the chrominance 
    fusion = imresize(img_chrom, size(img_lum));
    fusion = gray2ind(fusion, size(cmap, 1));
    fusion = ind2rgb(fusion, cmap);

    % combine the results
    fusion = rgb2ycbcr(fusion);
    fusion(:,:,1) = img_lum;
    fusion = ycbcr2rgb(fusion);

end