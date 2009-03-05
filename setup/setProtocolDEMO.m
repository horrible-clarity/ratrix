function r = setProtocolDEMO(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});

rewardSizeULorMS          =50;
requestRewardSizeULorMS   =10;
requestMode               ='first'; 
msPenalty                 =1000;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;

constantRewards=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

freeDrinkLikelihood=0.003;
fd = freeDrinks(sm,freeDrinkLikelihood,constantRewards);

freeDrinkLikelihood=0;
fd2 = freeDrinks(sm,freeDrinkLikelihood,constantRewards);

percentCorrectionTrials=.5;

% {'flickerRamp',[0 .5]}
vh=nAFC(sm,percentCorrectionTrials,constantRewards,[],[],[],{'off'},true,'ptb');

pixPerCycs              =[20];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =.04;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65;
%screen('resolutions') returns values too high for our NEC MultiSync FE992's -- it must just consult graphics card
maxWidth                =1024;
maxHeight               =768;
scaleFactor             =[1 1];
interTrialLuminance     =.5;
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

pixPerCycs=[20 10];
distractorOrientations=[0];
discrimStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

ims=fullfile('Rodent-Data','PriyaV','other stimuli sets','paintbrush_flashlight'); %'\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\other stimuli sets\paintbrushMORPHflashlightEDF';
if ispc
    imageDir=fullfile('\\Reinagel-lab.ad.ucsd.edu','rlab',ims);
elseif ismac
    imageDir=fullfile('/Volumes','RLAB',ims);
else
    error('only works on windows and mac')
end

background=0;
ypos=0;
ims=dir(fullfile(imageDir,'*.png'));
if isempty(ims)
    error('couldn''t find image directory')
end

trialDistribution={};
for i=1:floor(length(ims)/2)
    [junk n1 junk junk]=fileparts(ims(i).name);
    [junk n2 junk junk]=fileparts(ims(length(ims)-(i-1)).name);
    trialDistribution{end+1}={{n1 n2} 1};
end
imageStim = images(imageDir,ypos,background,maxWidth,maxHeight,scaleFactor,interTrialLuminance,trialDistribution,'normal',[1 1],false,[0 0]);

d=2; %decrease to broaden
gran=100;
x=linspace(-d,d,gran);
[a b]=meshgrid(x);

ports=cellfun(@uint8,{1 3},'UniformOutput',false);
[noiseSpec(1:length(ports)).port]=deal(ports{:});

% stim properties:
% in.distribution               'binary', 'uniform', or one of the following forms:
%                                   {'sinusoidalFlicker',[temporalFreqs],[contrasts],gapSecs} - each freq x contrast combo will be shown for equal time in random order, total time including gaps will be in.loopDuration
%                                   {'gaussian',clipPercent} - choose variance so that clipPercent of an infinite stim would be clipped (includes both low and hi)
%                                   {path, origHz, normalizedClipVal} -  path is to a file (either .txt or .mat, extension omitted, .txt loadable via load()) containing a single vector of stim values named 'noise', with original sampling rate origHz.  will clip values over normalizedClipVal.
% in.contrast                   above stim has range 0-1 (and is already clipped), then multiply stim by this value
% in.offset                     normalized value to add to stim after multiplying by contrast.  after this, values outside 0-1 will saturate.
% in.startFrame                 'randomize' or integer indicating fixed frame number to start with
% in.loopDuration               in seconds (will be rounded to nearest multiple of frame duration, if distribution is a file, pass 0 to loop the whole file)
%                               to make uniques and repeats, pass {numRepeatsPerUnique numCycles cycleDurSeconds} - a cycle is a whole set of repeats and one unique - distribution cannot be sinusoidalFlicker

[noiseSpec.distribution]         =deal({'gaussian' .01});
[noiseSpec.offset]               =deal(0);
[noiseSpec.contrast]             =deal(1);
[noiseSpec.startFrame]           =deal(uint8(1)); %deal('randomize');
[noiseSpec.loopDuration]         =deal(1);

% patch properties:
% in.locationDistribution       2-d density, will be normalized to stim area
% in.maskRadius                 std dev of the enveloping gaussian, normalized to diagonal of stim area (values <=0 mean no mask)
% in.patchDims                  [height width]
% in.patchHeight                0-1, normalized to stim area height
% in.patchWidth                 0-1, normalized to stim area width
% in.background                 0-1, normalized (luminance outside patch)

[noiseSpec.locationDistribution]=deal(reshape(mvnpdf([a(:) b(:)],[-d/2 d/2]),gran,gran),reshape(mvnpdf([a(:) b(:)],[d/2 d/2]),gran,gran));
[noiseSpec.maskRadius]           =deal(.045);
[noiseSpec.patchDims]            =deal(uint16([50 50]));
[noiseSpec.patchHeight]          =deal(.4);
[noiseSpec.patchWidth]           =deal(.4);
[noiseSpec.background]           =deal(.5);

% filter properties:
% in.orientation                filter orientation in radians, 0 is vertical, positive is clockwise
% in.kernelSize                 0-1, normalized to diagonal of patch
% in.kernelDuration             in seconds (will be rounded to nearest multiple of frame duration)
% in.ratio                      ratio of short to long axis of gaussian kernel (1 means circular, no effective orientation)
% in.filterStrength             0 means no filtering (kernel is all zeros, except 1 in center), 1 means pure mvgaussian kernel (center not special), >1 means surrounding pixels more important
% in.bound                      .5-1 edge percentile for long axis of kernel when parallel to window

[noiseSpec.orientation]         =deal(-pi/4,pi/4);
[noiseSpec.kernelSize]           =deal(.5);
[noiseSpec.kernelDuration]       =deal(.2);
[noiseSpec.ratio]                =deal(1/3);
[noiseSpec.filterStrength]       =deal(1);
[noiseSpec.bound]                =deal(.99);

maxWidth               = 800;
maxHeight              = 600;
scaleFactor            = 0;

noiseStim=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


[noiseSpec.orientation]         =deal(0);
[noiseSpec.locationDistribution]=deal([0 0;1 0], [0 0;0 1]);
[noiseSpec.distribution]         =deal('binary');
[noiseSpec.contrast]             =deal(1);
[noiseSpec.maskRadius]           =deal(100);
[noiseSpec.kernelSize]           =deal(0);
[noiseSpec.kernelDuration]       =deal(0);
[noiseSpec.ratio]                =deal(1);
[noiseSpec.filterStrength]       =deal(0);
[noiseSpec.patchDims]            =deal(uint16([2 2]));
[noiseSpec.patchHeight]          =deal(.1);
[noiseSpec.patchWidth]           =deal(.1);

unfilteredNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

led=nAFC(sm,percentCorrectionTrials,constantRewards,[],[],[],{'off'},false,'LED');

if ismac
    ts001 = '/Users/eflister/Desktop/ratrix trunk/classes/protocols/stimManagers/@flicker/ts001';
else
    ts001 = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\hateren\ts001';
end

[noiseSpec.distribution]         =deal({ts001, 1200, 12800/32767}); %for clip val, see pam email to Alex Casti on January 25, 2005, and Reinagel Reid 2000
numRepeatsPerUnique=4;
[noiseSpec.loopDuration]         =deal({uint32(numRepeatsPerUnique) uint32(32) uint32((numRepeatsPerUnique+1)*8)}); %{numRepeatsPerUnique numCycles cycleDurSeconds}

[noiseSpec.locationDistribution]=deal(1);
[noiseSpec.contrast]             =deal(1);
[noiseSpec.patchDims]            =deal(uint16([1 1]));
[noiseSpec.patchHeight]          =deal(1);
[noiseSpec.patchWidth]           =deal(1);

hateren=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal('gaussian', .01);

fullfieldFlicker=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[1 5 10 25 50],[.1 .25 .5 .75 1],.1}); %temporal freqs, contrasts, gapSecs
[noiseSpec.loopDuration]         =deal(5*5*5);
[noiseSpec.contrast]             =deal(1);
[noiseSpec.patchHeight]          =deal(1);
[noiseSpec.patchWidth]           =deal(1);
crftrf=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};

ts1 = trainingStep(fd, freeStim, repeatIndefinitely(), noTimeOff(), svnRev);   %stochastic free drinks
ts2 = trainingStep(fd2, freeStim, repeatIndefinitely(), noTimeOff(), svnRev);  %free drinks
ts3 = trainingStep(vh, freeStim, repeatIndefinitely(), noTimeOff(), svnRev);   %go to stim
ts4 = trainingStep(vh, discrimStim, repeatIndefinitely(), noTimeOff(), svnRev);%orientation discrim
ts5 = trainingStep(vh, imageStim,  repeatIndefinitely(), noTimeOff(), svnRev); %morph discrim
ts6 = trainingStep(vh, noiseStim,  repeatIndefinitely(), noTimeOff(), svnRev); %filteredNoise discrim
%ts7 = trainingStep(vh, unfilteredNoise,  repeatIndefinitely(), noTimeOff(), svnRev); %unfiltered goToSide
ts7 = trainingStep(vh, hateren,  repeatIndefinitely(), noTimeOff(), svnRev); %hateren
ts8 = trainingStep(vh, fullfieldFlicker,  repeatIndefinitely(), noTimeOff(), svnRev); %fullfieldFlicker
ts9 = trainingStep(vh, crftrf,  repeatIndefinitely(), noTimeOff(), svnRev); %crf/trf

p=protocol('gabor test',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8, ts9});
stepNum=uint8(9);

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolDEMO','edf');
end