function [sigSpots2D sigSpots3D]=getSignificantSTASpots(sta,spikeCount,stimMean,contrast,medianFilter,alpha);
%     getSignificantSTASpots(sta,spikeCount,stimMean=empiricMean, contrast=1,medianFilter=logical(ones(3)),alpha=.05);
% sigSpots2D labels of the spots that are siginifcant in the time slice.  
% 0= not signifcant
% 1= belongs to group 1
% 2= belongs to group 2... etc 
% with the most significant pixels
% sig spots3D is returned but might not be used yet by any users,
% it contains the labels for each 2D processed time slice.  spot #1:N in time slice t 
% do NOT have unique values across time slices (ie. there are many ID==1's)
% and may or may not be contiguous in space-time. 

if ~exist('contrast','var') || isempty(contrast)
    contrast=1;
end

if ~exist('medianFilter','var') || isempty(medianFilter)
    medianFilter=logical(ones(3));
else
    if all(size(medianFilter)~=[3 3])
        error('must be defined by local 2D neighborhood')
    end
end

if ~exist('alpha','var') || isempty(alpha)
    alpha=.05;
end

if ~exist('stimMean','var') || isempty(stimMean)
    stimMean=mean(sta(:));
    warning('the empiric mean is only a crude estimate, it will be wrong if there is an asymetric-luminance receptive field present')
end

nullStd=sqrt(spikeCount)*contrast; % double check this
zscore = erf(abs((sta-stimMean)/nullStd));
significant = zscore > (1 - alpha/2);

% do the calculation now
% sta, spikeCount, stim, numFrames, contrast, alpha, rf
%                 sta = mean(triggers,3);
% denoise significant to see if we have a good receptive field
% use a 3x3 box median filter, followed by bwlabel (to count the number of spots left)
%                 box = ones(3,3);
%                 cross = zeros(3,3); cross([2,4,5,6,8]) = 1;

midpoint=ceil(length(medianFilter(:))/2);
sigSpots3D=nan(size(sta));
filtered=nan(size(sta));
T=size(sta,3);
for t=1:T
    filtered(:,:,t) = ordfilt2(significant(:,:,t),midpoint,medianFilter);
    [sigSpots3D numSpots] = bwlabel(filtered(:,:,t),8); % use 8-connected (count 2D diagonal connections)
end

% connect in 3D
%[sigSpots3D numSpots] =bwlabeln(filtered,26); % use 26-connected (count 3D diagonal connections)
% bigSpots = bwareaopen(BW,atLeastNpixels)

%num significant pixels per time step
sigPixels=reshape(sum(sum(sigSpots3D,1), 2),T,[]); 


%push to 2D
%only earliest time if there is a tie for the max number of significant pixels
whichTime=find(sigPixels==max(sigPixels));
sigSpots2D=mean(sigSpots3D(:,:,whichTime(1))>0,3)>0;