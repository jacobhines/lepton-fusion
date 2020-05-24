function QNR = getQNR(fusion, vis, thr, vis_lp)
    % calculates the quality index without reference
    
    alpha = 0;
    beta = 1;
    
    DL = 0;
    vis_lp = imresize(vis_lp, size(thr));
    
    DS = abs(getQ(fusion, vis) - getQ(thr, vis_lp));
    
    QNR = ((1-DL).^(alpha)) .* ((1-DS).^(beta));

end