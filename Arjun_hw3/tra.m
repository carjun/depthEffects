tic;
imL=rgb2gray(imread('C:\Users\arjun\Documents\vt_stuff\CV Lynn Abott\project\stereo-pairs\tsukuba\imL.png'));
imR=rgb2gray(imread('C:\Users\arjun\Documents\vt_stuff\CV Lynn Abott\project\stereo-pairs\tsukuba\imR.png'));
% imL=rgb2gray(imread('C:\Users\arjun\Documents\vt_stuff\CV Lynn Abott\project\stereo-pairs\teddy\imL.png'));
% imR=rgb2gray(imread('C:\Users\arjun\Documents\vt_stuff\CV Lynn Abott\project\stereo-pairs\teddy\imR.png'));
template_size=7;
max_disp_colsize=24;

%-----------------------------------------------------------------------
% initialize disparity map to same size as imL
disparity_map= zeros(size(imL,1),size(imL,2));
%
% template traverses over imL
for jj=1:size(imL,1)-template_size+1
    for ii=1:size(imL,2)-template_size+1 % one horizontal sweep
        template= imL(jj:jj+template_size-1,ii:ii+template_size-1);
        %showTemplatePos(template,imL, ii, jj);
        templateCenterRow=jj+floor(template_size/2);
        templateCenterCol=ii+floor(template_size/2);
        %showTemplatePos([1,1],imL, templateCenterCol, templateCenterRow);
        
        %--------------------------------------------------------------
        % match template against disparity window in imR
        disp_win_colst= max(1,templateCenterCol-floor(2*max_disp_colsize/3));
        disp_win_colend= min(size(imR,2), templateCenterCol+floor(max_disp_colsize/3));
        % Note : start and end rows of disparity window are same as template
        disp_window= imR(jj:jj+template_size-1,disp_win_colst:disp_win_colend);
        %showDisparityWinPos(disp_window,imR, disp_win_colst,disp_win_colend, jj);
        
        % Look for match for template in disparity window
        disp_vector= ones(size(disp_window,2)-template_size,1);
        disp_vect_center= templateCenterCol - disp_win_colst; 
        %disp(size(disp_vector));
        for i=1:size(disp_window,2)-template_size
            disp_vector(i)= sum(sum(abs(template - disp_window(:,i:i+template_size-1))));
        end
        %disp(disp_vector);
        %disp(min(disp_vector));
        %tic; pause(10); toc;
        %------------------------------------------------------------
        
        % Store min disp position from disp_vector in disparity_map
        [min_val, min_pos]=min(disp_vector);
        %disp(min_val);
        %disp(min_pos);
        %tic; pause(10); toc;
        %disparity_map(templateCenterRow,templateCenterCol)= abs(min_pos-templateCenterCol);
        disparity_map(templateCenterRow,templateCenterCol)= abs(min_pos-disp_vect_center);
    end    
end
%--------------------------------------------------------------------------

% Display output disparity map
imshow(mat2gray(disparity_map));
toc;

%--------------------------------------------------------------------------
% Output :
%Elapsed time is 19.791034 seconds.




