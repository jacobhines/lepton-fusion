function [img_registered, data] = registerImage(img, ref, edgeMethod)
    
    % range of empirical scale factors relating visible and thermal images
    c = linspace(1.15, 1.3, 10);

    % initialize containers
    maxCorr = zeros(1, length(c));
    
    % detect edges
    eimg = edge(img,edgeMethod);
    
    % find maximum correlations over different scale factors
    for ii = 1:length(c)
        % resize reference image
        ref_resized = imresize(ref, c(ii).*size(eimg));
        
        % detect reference edges
        eref = edge(ref_resized, edgeMethod);
        
        % calculate edge-edge correlation matrix
        corr = conv2(rot90(eimg,2), eref, 'same');
        
        % store maximum correlation
        maxCorr(ii) = max(corr(:));
    end
    
    % select scale factor that returns maximum edge-edge correlation
    [~, Ic] = max(maxCorr);
    cOpt = c(Ic);
    
    ref_resized = imresize(ref, cOpt.*size(eimg));
    eref = edge(ref_resized, edgeMethod);
    corr = conv2(rot90(eimg,2), eref, 'same');
    
    % select shift that maximizes edge-edge correlation
    [M1, I1] = max(corr);
    [~, I2] = max(M1);
    I1 = I1(I2);

    shift = [I1 I2] - round(size(img)./2);
    shift = fliplr(shift);

    % generate registered image
    padsize = round((size(ref_resized)-size(img))./2);
    img_registered = padarray(img, padsize);
    img_registered = imtranslate(img_registered, shift);
    
    % store edges
    eimg_registered = padarray(eimg, padsize);
    eimg_registered = imtranslate(eimg_registered, shift);
    eref_resized = imresize(eref, size(eimg_registered));
    
    % collect variables for return
    data.shift = shift;
    data.ref_resized = ref_resized;
    data.eimg_registered = eimg_registered;
    data.eref_resized = eref_resized;
    data.correlation = corr;
    data.maxCorr = maxCorr;
    data.cOpt = cOpt;
end
