
%% Run this to demo stereo disparity extraction
 
% i1 = imread('tsuR.png');  %right image
% i2 = imread('tsuL.png');  %left image
% i1 = imread('C:\Users\arjun\Documents\vt_stuff\CV Lynn Abott\project\stereo-pairs\cosima\imL.png');  %left image
% i2 = imread('C:\Users\arjun\Documents\vt_stuff\CV Lynn Abott\project\stereo-pairs\cosima\imR.png');  %right image
i1 = imread('C:\Users\arjun\Documents\vt_stuff\CV Lynn Abott\project\stereo-pairs\medeival\imR.png');
i2 = imread('C:\Users\arjun\Documents\vt_stuff\CV Lynn Abott\project\stereo-pairs\medeival\imL.png');

maxs = 23; %maximum disparity between the two images

%-- here's the main call
[d p] = stereo(i1,i2, maxs);

%-- run this instead if filtering causes problems
%   d = stereo_nofilter(i1,i2, maxs); p = d;

%--  Display stuff
subplot(2,2,1), imshow(i2); title('left image');
subplot(2,2,2), imshow(i1); title('right image');
subplot(2,2,3), imagesc(p); title('original disparity'); axis image;
subplot(2,2,4), imagesc(d); title('filtered disparity'); axis image;