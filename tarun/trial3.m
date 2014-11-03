I1 = imread('dofpro_chessRGB.jpg');
[height1 width1 d1] = size(I1);
I2 = imread('dofpro_chessDM.jpg');
[height2 width2 d2] = size(I2);

figure;
I1_gray=I1;
imshow(I1_gray);

figure;
I2_gray=I2;
imshow(I2_gray);

I2_thresh=im2bw(I2_gray,230/255);

I2_thresh=uint8(I2_thresh);

I_thresh(:,:,1)=I1_gray(:,:,1).*I2_thresh;
I_thresh(:,:,2)=I1_gray(:,:,2).*I2_thresh;
I_thresh(:,:,3)=I1_gray(:,:,3).*I2_thresh;
figure;
imshow(I_thresh);

I_minus=I1_gray-I_thresh;
% figure;
% imshow(I_minus);

 h = fspecial('gaussian', [height1 width1], 6.0);
g = imfilter(I_minus, h); 
% figure;
% imshow(g);

I_blur=g+I_thresh;
figure;
imshow(I_blur);
