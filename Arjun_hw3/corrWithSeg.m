function corrWithSeg()
tic;
depthImg= rgb2gray(imread('intensity+5grad.png'));
segImg= rgb2gray(imread('seg_a01_k30_resized.png'));
hist= imhist(segImg(segImg~=0)); % Histogram of non-zero vals of segImg
%plot(hist);
% stores already visited regions as white (1s)
corrImg= zeros(size(segImg));

% Traverse over each discrete Object/Color in segmented image
for color=1:size(hist)
    %for color=1:15
    % color corresponds to position. color-1 corresponds to color
    
    % Find ROIs that have same color in segmented image
    bw_roi = roicolor(segImg,color-1,color-1);
    %imshow(bw_roi);
    cc= bwconncomp(bw_roi); % Find connected components
    % Loop through each region in ROI
%     disp('No of connected objects:');
%     disp(cc.NumObjects);
    idxList= regionprops(cc,'PixelList');
    %disp(idxListSize);
    for region= 1:cc.NumObjects
        pixelList= idxList(region).PixelList;
%         disp('No of pixels in region:');
%         disp(size(pixelList));
        %for i=1:size(pixelList,1)
        %if (pixelList(i,1)<=size(depthImg,2) &&
        %pixelList(i,2)<=size(depthImg,1)) NOTE : TBD
        %if ( size(pixelList,1)>2 )
            disp('assigning vals');
            % copy depth values in ROI
            temp= zeros(size(pixelList,1),1);
            for i=1:size(pixelList,1)
                temp(i)=depthImg(pixelList(i,2),pixelList(i,1));
            end
            % compute mode
            temp_mode= mode(temp);
            disp('mode :');
            disp(temp_mode);
            % assign pixel vals to mode val
            for i=1:size(pixelList,1)
                corrImg(pixelList(i,2),pixelList(i,1))= temp_mode;% assign mode
            end
        %end
    end
end
figure;imshow(mat2gray(corrImg));
%filledCorrImg = imfill(corrImg); %fills holes in the grayscale image I. In this syntax, 
% a hole is defined as an area of dark pixels surrounded by lighter pixels
figure; imagesc(corrImg); colorbar;
%figure;imshow(mat2gray(filledCorrImg));
%figure; imagesc(filledCorrImg); colorbar;
toc;
end