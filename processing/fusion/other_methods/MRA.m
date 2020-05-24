function fusion = MRA(thr, vis, gfunct, lpfunct)
    
    thr_tilde = imresize(thr, size(vis));
    
    vis_lp = lpfunct(vis);
    g = gfunct(thr_tilde, vis_lp);
    
    g(g<0) = 0;
    
    fusion = thr_tilde + g.*(vis - vis_lp);
    
end