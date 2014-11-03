function [Gx, Gy, Gz] = getVideoGradients( flow )
%GETVIDEOGRADIENTS Returns discrete spatio-temporal derivatives (x,y, and time)
% Input:
%  flow - [height x width x 2 x numFrames] flow field. If numFrames==1 or
%         the flow is unknown, set flow = zeros(height,width,2,numFrames) 
%         to return only spatial gradients (Gx,Gy); Gz will be the identity
% Output:
%  Gx - [height*width, height*width] sparse horizontal gradient operator
%  Gy - [height*width, height*width] sparse vertical gradient operator
%  Gz - [height*width, height*width] sparse time gradient operator
%%%%%%%%%%%   Begin getVideoGradients   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [h,w,~,K] = size(flow);
    N = h*w*K; %number of pixels in entire video
    
    %Horizontal adjacencies
    left = -ones(N,1);
    left( w*h*repmat(1:K,[h,1])' - repmat((1:h),[K,1])+1 ) = 0;
    Gx = spdiags([left, ones(N,1)], [-h,0], N, N);
    
    %Vertical adjacencies
    top = -ones(N,1);
    top(h:h:end) = 0;
    Gy = spdiags([top,ones(N,1)], [-1,0], N, N);
    
    %Temporal adjacencies (based on flow)
    Nk = w*h;
    [X,Y] = meshgrid(1:w,1:h);
    IDX = sub2ind([h,w],Y(:),X(:));
    rowidx = zeros(Nk*(K-1),1);
    colidx = zeros(Nk*(K-1),1);
    for i=1:K-1
        flowX = round(X+flow(:,:,1,i));
        flowY = round(Y+flow(:,:,2,i));
        inside = flowX>=1 & flowX<=w & flowY>=1 & flowY<=h;
        numInside = sum(inside(:));
        rowidx( (1:numInside)+(i-1)*Nk ) = IDX(inside) + (i-1)*Nk;
        colidx( (1:numInside)+(i-1)*Nk ) = sub2ind([h,w],flowY(inside),flowX(inside)) + i*Nk;
    end
    rowidx(rowidx==0) = [];
    colidx(colidx==0) = [];
    Gz = sparse(rowidx, colidx, -ones(size(rowidx)), N, N);
    Gz = Gz + spdiags(sum(abs(Gz),2),0,N,N);
    Gz = Gz + spdiags(double(diag(Gz)==0),0,N,N); %bdry conditions = 0
end
