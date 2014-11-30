function showDisparityWinPos(disp_window,imR, disp_win_colst,disp_win_colend, jj)
    % show position of disparity window in image R
    dummy= zeros(size(imR,1),size(imR,2));
    % disparity position (white box against black bg)
    dummy(jj:jj+size(disp_window,1)-1,disp_win_colst:disp_win_colend)= ones(size(disp_window,1),disp_win_colend-disp_win_colst+1);
    imshow(dummy);
    tic; pause(0.0001); toc;
end