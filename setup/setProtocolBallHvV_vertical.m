function r = setProtocolHvV_vertical(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =80;
requestRewardSizeULorMS   =0;
requestMode               ='first';
msPenalty                 =3500;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;

% sca
% keyboard

if ~isscalar(subjIDs)
    error('expecting exactly one subject')
end
 switch subjIDs{1}

  case 'g62b1lt'     %moved to HvV_vertical 2/19/14   
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 140;
       msPenalty                 =4000; 
     
  case 'g62b3rt'          %changed 2/14/14
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 65; 
       msPenalty               = 3750; 
     
%   case 'g54aa7lt'
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 90;
%        msPenalty                 =4250; 
       
%      case 'gcam44lt'  %changed 1/4/14
%         requestRewardSizeULorMS = 0;
%         rewardSizeULorMS        = 180; 
%         msPenalty                 =4250; 
        
%    case 'gcam25rt' %retired 1/4/14
%         requestRewardSizeULorMS = 0;
%         rewardSizeULorMS        = 60;
        
%    case 'bfly24lt'
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 80; 
%        msPenalty                 =4000; 
       

       
           
       
    otherwise
        warning('unrecognized mouse, using defaults')
end

noRequest = constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

percentCorrectionTrials = .5;

maxWidth  = 1920;
maxHeight = 1080;

[w,h] = rat(maxWidth/maxHeight);
textureSize = 10*[w,h];
zoom = [maxWidth maxHeight]./textureSize;

svnRev = {'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode = 'session';

interTrialLuminance = .5;

stim.gain = 0.7 * ones(2,1);
stim.targetDistance = 500 * ones(1,2);
stim.timeoutSecs = 10;
stim.slow = [40; 80]; % 10 * ones(2,1);
stim.slowSecs = 1;
stim.positional = false;
stim.cue = true;
stim.soundClue = false;

pixPerCycs             = [100]; %*10^9;
targetOrientations     = 0
distractorOrientations = []; %-targetOrientations;
mean                   = .5;
radius                 = .35;
contrast               = 1;
thresh                 = .00005;
normalizedPosition      = [0.25 0.75];
scaleFactor            = 0; %[1 1];
axis                   = pi/2;








%%% abstract orientation (e.g. 0 = go left, pi/2 = go right)
targetOrientations = pi/2;
distractorOrientations = 0;

stim.stim = orientedGabors(pixPerCycs,{distractorOrientations [] targetOrientations},'abstract',mean,radius,contrast,thresh,normalizedPosition,maxWidth,maxHeight,scaleFactor,interTrialLuminance,[],[],axis);
%  ballSM = trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance);
 ballTM = ball(percentCorrectionTrials,sm,noRequest);
 
 ballSM = setReinfAssocSecs(trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance),1);
 %change stim to stay on for 1 sec after
 
 ts1 = trainingStep(ballTM, ballSM, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode); %ball
 
 p=protocol('mouse',{ts1});
%p=protocol('mouse',{ts1,ts2});

stepNum=uint8(1);
subj=getSubjectFromID(r,subjIDs{1});
[subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'LY01 (40,80), R=36','edf');
end