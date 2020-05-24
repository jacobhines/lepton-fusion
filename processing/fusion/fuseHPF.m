function fusion = fuseHPF(thr, vis, alpha)
    
    % calculate the gaussian std
    sigma = alpha*(size(vis)./size(thr))/2;
    
    % define the weight and lowpass functions
    lpFunct = @(vis) imgaussfilt(vis, sigma);

    % rescale the thermal image to match the visible image
    thrTilde = imresize(thr, size(vis));
    
    % calculate the lowpassed image and its weight
    visLP = lpFunct(vis);

    % generate the fused image
    fusion = thrTilde + (vis - visLP);
    
end