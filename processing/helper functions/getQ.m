function Q = getQ(x,y)
    % calculates the image quality index for images x and y

    xbar = mean(x(:));
    ybar = mean(y(:));
    
    var_x = var(x(:));
    var_y = var(y(:));
    
    C = cov(x,y);
    sigma_xy = C(1,2);
    
    numer = 4.*sigma_xy.*xbar.*ybar;
    denom = (var_x + var_y).*(xbar.^2 + ybar.^2);
    
    Q = numer/denom;
end