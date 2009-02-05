function [frameIndices frameTimes frameLengths correctedFrameIndices correctedFrameTimes correctedFrameLengths passedQualityTest] = ...
    getFrameTimes(pulseData, pulseDataTimes, sampleRate, warningBound, errorBound, ifi)
% calculate pulses and frameTimes based on pulseData
% frameIndices - the exact sample index for each pulse
% frameTimes - the time value retrieved from the index of a corresponding pulse (not unique!)
% each frame = three pulses (between the single pulses, ignore double pulses)
passedQualityTest = true; % changed to false temp - to not do analysis until we get better data (10.29.08)

% parameters for threshold
r = 1/20000; % time in seconds for pulse to go from peak to valley on one edge
amp = 4; % conservative amplitude of pulse peak
% threshold = max(min(amp / (r*sampleRate), 4), 0.05); % restricted to be 0.05<=threshold<=4
% 10/30/08 - decided to make the threshold fixed at 1.0 (even at sampling rate of 125kHz, TTL pulses still only take one sample)
% sometimes (randomly) due to aliasing will fall in between two samples
threshold = 1.0;

% need to fix threshold testing - if sampling rate too high, then the spike gets split among samples
% if we check for low enough threshold, each spike gets multiple counted, if too high threshold, misses these split spikes
% need to check low threshold, but throw out consecutive crosses of threshold (only keep last one as end of spike)
diff_vector = diff(pulseData); % first derivative
% find all pulses (places where the diff is > threshold)
pulses = find(diff_vector > threshold); % this is only the left edge of each pulse
% 10/30/08 - need to postprocess pulses (to weed out cases where the pulse is split among multiple samples)
% only take the last sample of the pulse (set threshold to be low then)
runs = diff(pulses);
runs(end+1) = -1; % automatically include the pulse if it happens on last sample
pulses = pulses(find(runs~=1));

% processing to adjust first pulse to be a single pulse (throw away starting pulses if they are part of the two-pulse signal)
gaps = diff(pulses(1:4));
if gaps(2) > gaps(1) && gaps(3) > gaps(1)
    % we started with two-pulse signal - throw away first two pulses
    pulses(1:2) = [];
elseif gaps(1) > gaps(3) && gaps(2) > gaps(3)
    % we started with two-pulse signal, but with one cut off - throw away first pulse
    pulses(1) = [];
else
    % we started with single-pulse signal - do nothing
end

frameTimes=[];
frameTimes(:,1) = pulseDataTimes(pulses(1:3:end-3));
frameTimes(:,2) = pulseDataTimes(pulses(4:3:end)-1);
frameIndices=[];
frameIndices(:,1) = pulses(1:3:end-3);
frameIndices(:,2) = pulses(4:3:end)-1;
% ==================================
correctedFrameTimes=frameTimes;
correctedFrameIndices=frameIndices; % default values are same as uncorrected; correct only those values that need it
for i=1:length(frameTimes) % indexes frameTimes
    % correct times and pulses
    if abs(1000*(frameIndices(i,2)-frameIndices(i,1))/sampleRate-ifi)>warningBound %are more than ifi, then must be missed frame
        % the same start time
        correctedFrameTimes(i,1)=frameTimes(i,1);
        % the corrected end time (estimated using ifi)
        correctedFrameTimes(i,2)=frameTimes(i,1)+ifi-(1/sampleRate); % need to remove one sample's worth of time
        % the same start index
        correctedFrameIndices(i,1)=frameIndices(i,1);
        % the corrected end index (again, using ifi)
        [m correctedFrameIndices(i,2)]=min(abs(pulseDataTimes-correctedFrameTimes(i,2)));
    end
end
% ==================================


% error checking
% frameLengths = diff(frameIndices(:,1),1);
frameLengths = frameIndices(:,2)-frameIndices(:,1)+1;
correctedFrameLengths = correctedFrameIndices(:,2)-correctedFrameIndices(:,1)+1;
% due to aliasing, up to three values are acceptable
if length(unique(frameLengths)) > 3
    
    ifiMS=1000*unique(frameLengths)./sampleRate
    warning('found more than 3 unique frame lengths - miscalculation of frame start/stop indices');
    mn = mean(frameLengths);
%     if any(frameLengths < (1-errorBound)*mn)
%         warning('check your assumptions about frame start/stop calculation - found frameLength too small; failing quality test');
%         passedQualityTest = false;
%     elseif any(frameLengths < (1-warningBound)*mn)
%         warning('found frame lengths outside the warningBound (too small)');
%     elseif any(frameLengths > (1+warningBound)*mn)
%         droppedFrames = find(frameLengths > (1+warningBound)*mn);
%         totalNumberOfDroppedFrames = length(droppedFrames)
%         fractionOfDroppedFrames = totalNumberOfDroppedFrames / length(frameLengths)
%         warning('found dropped frames');
%         if any(frameLengths > (1+errorBound)*mn)
%             passedQualityTest = false;
%             warning('found frame lengths outside the errorBound (too long) - failling quality test');
%         end
%     end
end

%
% refreshRate = 60; % frames per second
% samplingRate = 10000; % samples per second
% numSamplesPerFrame = ceil((1/refreshRate) * samplingRate); % samples per frame
% frameTimes = zeros(floor(size(neuralDataTimes, 1) / numSamplesPerFrame), 2);
% % for now, we don't know how to handle the time between frames?
% frameTimes(:,1) = neuralDataTimes(1:numSamplesPerFrame:end-numSamplesPerFrame); % start times
% frameTimes(:,2) = neuralDataTimes(numSamplesPerFrame:numSamplesPerFrame:end); % stop times
%%% add something to make sure that the frame start/stop times are in troughs, not peaks
end % end function