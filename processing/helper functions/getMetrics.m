function metrics = getMetrics(params)
    % unpack images
    thr = params.thr;
    vis = params.vis;
    fusion = params.fusion;
    
    % calculate reference-free metrics
    metrics.qnr = getQNR(fusion, vis, thr, vis);
    metrics.entropy = entropy(fusion);
    
    % if thr is rescaled, calculate metrics referenced to ground truth
    if (params.thrScale < 1)
        
        groundTruth = params.thrGT;
        fusion_tilde = imresize(params.fusion, size(groundTruth));
    
        metrics.psnr = psnr(fusion_tilde, groundTruth);
        metrics.ssim = ssim(fusion_tilde, groundTruth);
        metrics.q = getQ(fusion_tilde, groundTruth);
    end
   
end