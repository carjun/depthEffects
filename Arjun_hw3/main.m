tic;
imL=rgb2gray(imread('imL.png'));
imR=rgb2gray(imread('imR.png'));

template_size=21;
max_disp_colsize=40;
grad_weight= 5;
%-----------------------------------------------------------------------
% initialize disparity map to same size as imL
disparity_map_intensity= zeros(size(imL,1),size(imL,2));
disparity_map_gx= zeros(size(imL));
disparity_map_gy= zeros(size(imL));
%
% template traverses over imL
for jj=1:size(imL,1)-template_size+1
    for ii=1:size(imL,2)-template_size+1 % one horizontal sweep
        template= imL(jj:jj+template_size-1,ii:ii+template_size-1);
        %showTemplatePos(template,imL, ii, jj);
        templateCenterRow=jj+floor(template_size/2);
        templateCenterCol=ii+floor(template_size/2);
        %showTemplatePos([1,1],imL, templateCenterCol, templateCenterRow);
        [temp_gx,temp_gy]= gradient(im2double(template));
        %--------------------------------------------------------------
        % match template against disparity window in imR
        disp_win_colst= max(1,templateCenterCol-floor(2*max_disp_colsize/3));
        disp_win_colend= min(size(imR,2), templateCenterCol+floor(max_disp_colsize/3));
        % Note : start and end rows of disparity window are same as template
        disp_window= imR(jj:jj+template_size-1,disp_win_colst:disp_win_colend);
        %showDisparityWinPos(disp_window,imR, disp_win_colst,disp_win_colend, jj);
        [disp_win_gx,disp_win_gy] = gradient(im2double(disp_window)); % x,y gradients
        
        % Look for match for template in disparity window
        disp_vector= ones(size(disp_window,2)-template_size,1);
        gradx_disp_vector= ones(size(disp_window,2)-template_size,1);
        grady_disp_vector= ones(size(disp_window,2)-template_size,1);
        %
        disp_vect_center= templateCenterCol - disp_win_colst; 
        %disp(size(disp_vector));
        for i=1:size(disp_window,2)-template_size
            disp_vector(i)= sum(sum(abs(template - disp_window(:,i:i+template_size-1))));
            gradx_disp_vector(i)= sum(sum(abs(temp_gx - disp_win_gx(:,i:i+template_size-1))));
            grady_disp_vector(i)= sum(sum(abs(temp_gy - disp_win_gy(:,i:i+template_size-1))));
        end
        %tic; pause(10); toc;
        %------------------------------------------------------------
        
        % Store min disp position from disp_vector in disparity_map
        [min_val, min_pos]=min(disp_vector);
        [min_val_gx, min_pos_gx]=min(gradx_disp_vector);
        [min_val_gy, min_pos_gy]=min(grady_disp_vector);

        disparity_map_intensity(templateCenterRow,templateCenterCol)= abs(min_pos - disp_vect_center);
        disparity_map_gx(templateCenterRow,templateCenterCol)= abs(min_pos_gx - disp_vect_center);
        disparity_map_gy(templateCenterRow,templateCenterCol)= abs(min_pos_gy - disp_vect_center);
    end    
end

%--------------------------------------------------------------------------
% Display output disparity maps
% Correlate with graph cut segmented image
dmap_gray= mat2gray(disparity_map_intensity);
final_dmap= mat2gray(dmap_gray + grad_weight.*(mat2gray(disparity_map_gx) + mat2gray(disparity_map_gy)));
figure; imagesc(final_dmap);
corrWithSeg(); 
%------------------------------------------------------------------------------------------------
toc;
