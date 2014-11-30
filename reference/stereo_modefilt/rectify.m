%Read images
% imL= imread('stereo_pairs/tsukuba/imL.png');
% imR= imread('stereo_pairs/tsukuba/imR.png');
imL= imread('aL.jpg');
imR= imread('aR.jpg');
%
imLgray = im2double(rgb2gray(imL));
imRgray = im2double(rgb2gray(imR));
%
imshowpair(imLgray, imRgray,'montage');
title('imL (left); imR (right)');
%color composite showing pixel-wise differences btw imL, imR
figure; imshowpair(imLgray,imRgray,'ColorChannels','red-cyan');
title('Composite Image (Red - Left Image, Cyan - Right Image)');

%find blob-like (Interest Points) features in both images
blobs1 = detectSURFFeatures(imLgray, 'MetricThreshold', 2000);
blobs2 = detectSURFFeatures(imRgray, 'MetricThreshold', 2000);

% Visualize the location and scale 30 strongest SURF features
figure; imshow(imLgray); hold on;
plot(blobs1.selectStrongest(30));
title('Thirty strongest SURF features in imL');

figure; imshow(imRgray); hold on;
plot(blobs2.selectStrongest(30));
title('Thirty strongest SURF features in imR');

% find candidate point correspondences. 
% For each blob, compute the SURF feature vectors (descriptors)
[features1, validBlobs1] = extractFeatures(imLgray, blobs1);
[features2, validBlobs2] = extractFeatures(imRgray, blobs2);

% Use SAD to determine indices of matching features.
indexPairs = matchFeatures(features1,features2,'Metric','SAD','MatchThreshold',5);

% locations of matched points
matchedPoints1 = validBlobs1.Location(indexPairs(:,1),:);
matchedPoints2 = validBlobs2.Location(indexPairs(:,2),:);

% matching points on top of the composite image
figure; showMatchedFeatures(imL, imR, matchedPoints1, matchedPoints2);
legend('Putatively matched points in imL', 'Putatively matched points in imR');

%  Remove Outliers Using Epipolar Constraint
[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'RANSAC', ...
  'NumTrials', 10000, 'DistanceThreshold', 0.1, 'Confidence', 99.99);

if status ~= 0 || isEpipoleInImage(fMatrix, size(imLgray)) ...
  || isEpipoleInImage(fMatrix', size(imRgray))
  error(['For the rectification to succeed, the images must have enough '...
    'corresponding points and the epipoles must be outside the images.']);
end

inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

figure; showMatchedFeatures(imLgray, imRgray, inlierPoints1, inlierPoints2);
legend('Inlier points in imL', 'Inlier points in imR');

% Rectify Images
[t1, t2] = estimateUncalibratedRectification(fMatrix, ...
  inlierPoints1, inlierPoints2, size(imRgray));

%Rectify the images using projective transformations, t1 and t2
geoTransformer = vision.GeometricTransformer('TransformMatrixSource', 'Input port');
imLRect = step(geoTransformer, imLgray, t1);
imRRect = step(geoTransformer, imRgray, t2);

% transform the points to visualize them together with the rectified images
pts1Rect = tformfwd(double(inlierPoints1), maketform('projective', double(t1)));
pts2Rect = tformfwd(double(inlierPoints2), maketform('projective', double(t2)));

%figure; showMatchedFeatures(imLRect, imRRect, pts1Rect, pts2Rect);
legend('Inlier points in rectified imL', 'Inlier points in rectified imR');
imwrite(imLRect,'imLRect.png');
imwrite(imRRect,'imRRect.png');
Irectified = cvexTransformImagePair(imLgray, t1, imRgray, t2);
figure, imshow(Irectified);
title('Rectified Stereo Images (Red - Left Image, Cyan - Right Image)');

%cvexRectifyImages('parkinglot_left.png', 'parkinglot_right.png');

%%
%References 
%[1] Trucco, E; Verri, A. "Introductory Techniques for 3-D Computer Vision." Prentice Hall, 1998.
%[2] Hartley, R; Zisserman, A. "Multiple View Geometry in Computer Vision." Cambridge University Press, 2003.
%[3] Hartley, R. "In Defense of the Eight-Point Algorithm." IEEE Transactions on Pattern Analysis and Machine Intelligence, v.19 n.6, June 1997.
%[4] Fischler, MA; Bolles, RC. "Random Sample Consensus: A Paradigm for Model Fitting with Applications to Image Analysis and Automated Cartography." Comm. Of the ACM 24, June 1981.
%%

d = disparity(imLRect, imRRect, 'BlockSize', 35,'DisparityRange', [-6 10], 'UniquenessThreshold', 0);
%For the purpose of visualizing the disparity, replace the -realmax('single') marker with the minimum disparity value.
marker_idx = (d == -realmax('single'));
d(marker_idx) = min(d(~marker_idx));
%Show the disparity map. Brighter pixels indicate objects which are closer to the camera.
dispMap=mat2gray(d);
% get depth map and display :
% figure; imagesc(d);
figure; imshow(dispMap);
imwrite(dispMap,'disparityMap.png');