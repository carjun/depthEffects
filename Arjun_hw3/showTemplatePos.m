function showTemplatePos(template,imL, ii, jj)
    % show position of template in image
    dummy= zeros(size(imL,1),size(imL,2));
    % template position (white box against black bg)
    template_size= size(template,1);
    dummy(jj:jj+template_size-1,ii:ii+template_size-1)= ones(template_size,template_size);
    imshow(dummy);
    tic; pause(0.00001); toc;
end