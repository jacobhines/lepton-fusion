function [fusion, convergence] = fuseGTF(thr, vis, lambda, numItersADMM)
    % This function uses ADMM to fuse two input images according to
    % Gradient Transfer Function, based on gradient transfer and total
    % variation minimization.
    
    %ADMM parameter
    rho = 1;

    % resize thr to match vis
    thr = imresize(thr, size(vis));

    % convolution kernel for Dx and Dy
    dy = [0 0 0; 0 -1 0; 0 1 0];
    dx = [0 0 0; 0 -1 1; 0 0 0];

    % precomputations
    p2o = @(x) psf2otf(x, size(vis));
    dxFT    = p2o(dx);
    dxTFT   = conj(p2o(dx));
    dyFT    = p2o(dy);
    dyTFT   = conj(p2o(dy));

    Dfun = @(x, diFT) real(ifft2(diFT.*fft2(x)));

    xnumer = fft2(thr);
    xdenom = 1 + rho*(dxTFT.*dxFT + dyTFT.*dyFT);
    Dvis = zeros([size(vis), 2]);
    Dvis(:,:,1) = Dfun(vis, dxFT);
    Dvis(:,:,2) = Dfun(vis, dyFT);

    % initialize variables
    z = zeros([size(vis), 2]);
    u = zeros([size(vis), 2]);
    
    % keep track of convergence
    di = zeros(1, numItersADMM);
    dg = zeros(1, numItersADMM);
    
    % ADMM loop
    for iter = 1:numItersADMM
%         disp(['ADMM iteration ', num2str(iter)])

        % x update
        v = z - u + Dvis;
        v1 = v(:,:,1);
        v2 = v(:,:,2);

        xFT = (xnumer + rho*(dxTFT.*fft2(v1) + dyTFT.*fft2(v2)))./xdenom;
        x = real(ifft2(xFT));

        % z update
        Dx(:,:,1) = Dfun(x, dxFT);
        Dx(:,:,2) = Dfun(x, dyFT);
        v = Dx + u - Dvis;
        z = s_kappa(v, lambda/rho);

        % u update
        u = u + Dx - z - Dvis;
        
        di(iter) = norm(reshape(x-thr, [], 1), 2);
        dg(iter) = norm(reshape(Dx-Dvis, [], 1), 1);
        
    end

    fusion = x;
    convergence.normDeltaIntensity = di;
    convergence.normDeltaGradient = dg;

    % helper functions
    function z = s_kappa(v, kappa)
        z = zeros(size(v));

        z(v > kappa) = v(v > kappa) - kappa;
        z(v < -kappa) = v(v < -kappa) + kappa;
    end
end