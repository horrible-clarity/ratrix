function spec=stimSpec(varargin)
% stimSpec  class constructor. 
% spec=stimSpec(stimulus,criterion,stimType,rewardType,rewardDuration,framesUntilGrad,stochasticDistribution,isFinalPhase)
% spec=stimSpec(stimulus,criterion,stimType,rewardType,rewardDuration,framesUntilGrad,stochasticDistribution)
% the stimulus is the visual movie
% criterion is the phase transitions
% stimType is the format of the movie (toggle, loop, once-through, timedFrames, indexedFrames) - default is loop
    % it must be either a single char array, or a cell array (if time or frame indexed) of the form {'timedFrames', [indicies]}
% rewardType is either reward or airpuff
% rewardDuration is the duration of the reinforcement in milliseconds
% framesUntilTransition is the number of frames that this phase plays (exactly) and then graduates - this is useful if we want
% a wait phase that doesn't need a port response to move into discrim phase
% note that this only works for 'loop' stimType (because we count by frames, not by real time)
% stochasticDistribution is a two-element cell array - the first element is the distribution from which to pick an auto response
%   the second element is what port to auto trigger (given as a vector)

% criteria is the port(s) that will graduate from this phase - chosen from the set {'request', 'response', 'target', 'distractor', 'any', 'none'}
% isFinalPhase is a flag that indicates if this phase means the end of a trial

% fields in the stimSpec object
spec.stimulus = zeros(1,1,1);
spec.criterion = {[], 0};
spec.stimType = 'loop';
spec.rewardType = [];
spec.rewardDuration = 100;
spec.framesUntilTransition = [];
spec.stochasticDistribution = []; % for now the "distribution" is a unit random criterion between 0 and 1
spec.isFinalPhase = 0;


switch nargin
    case 0
        % if no input arguments, create a default object

        spec = class(spec,'stimSpec');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'stimSpec'))
            spec = varargin{1};
        % if single argument is a stimulus, use blank sounds and
        % rewardDuration
        elseif isa(varargin{1}, 'numeric')
            spec.stimulus = varargin{1};
            spec = class(spec,'stimSpec');
        else
            error('Input argument is not a stimSpec object or cell array of stim frames')
        end
	case 2
		% if we are given a stimulus and a criteria
        goodInput = 0;
		if isa(varargin{1}, 'numeric') && iscell(varargin{2})
			temp = varargin{2}; % this is the cell array that has key value pairs
			for i=1:2:length(varargin{2})-1 % check each transition port set
				if isa(temp{1}, 'numeric')
                    goodInput = 1;
				else
					error('Invalid port set specified');
				end
            end
		else
			error('Invalid inputs');
        end
        spec.stimulus = varargin{1};
		spec.criterion = varargin{2};
		spec = class(spec,'stimSpec');
        
    case 8
        % stimulus
        spec.stimulus = varargin{1};
		% criteria
        goodInput = 0;
		if iscell(varargin{2})
			temp = varargin{2}; % this is the cell array that has key value pairs
			for i=1:2:length(varargin{2})-1 % check each transition port set
				if isa(varargin{2}{i}, 'numeric')
					
                    goodInput=1;
				else
					error('Invalid port set specified');
				end
            end
            spec.criterion = varargin{2};   
		else
			error('Invalid inputs');
        end
        
        % stimType
        varargin{3}
        ischar(varargin(3))
        strcmp(varargin(3),'trigger')
        if ischar(varargin{3}) && (strcmp(varargin{3}, 'trigger') || strcmp(varargin{3}, 'loop') || ...
                strcmp(varargin{3}, 'once') || strcmp(varargin{3}, 'cache') || strcmp(varargin{3},'expert')) % handle single char arrays
            % error-check that if we want toggle mode, only a 2-frame movie
            if strcmp(varargin{3}, 'trigger') && size(spec.stimulus,3) ~= 2
                size(spec.stimulus,3)
                error('trigger mode only works with a 2-frame movie');
            end
            spec.stimType = varargin{3};
        elseif iscell(varargin{3})
            typeArray = varargin{3};
            if strcmp(typeArray{1}, 'timedFrames') || strcmp(typeArray{1}, 'indexedFrames')
                spec.stimType = varargin{3};
            else
                error('invalid specification of stimType in cell array format');
            end
        else
            error('stimType must be trigger, loop, once, cache, timedFrames, indexedFrames, or expert');
        end
        % rewardType
        if ischar(varargin{4}) && (strcmp(varargin{4}, 'reward') || strcmp(varargin{4}, 'airpuff') || ...
                strcmp(varargin{4},'rewardSizeMSorUL') || strcmp(varargin{4},'msPuff')) % 1/29/09 - also allow these flags to get value from reinforcementMgr
            spec.rewardType = varargin{4};
		elseif isempty(varargin{4})
			spec.rewardType = []; % no reward/airpuff here
        else
            error('rewardType must be reward or airpuff');
        end
        % rewardDuration
        if varargin{5} > 0
            spec.rewardDuration = varargin{5};
        else
            error('rewardDuration must be longer than zero');
        end
        % framesUntilTransition
        if isscalar(varargin{6}) && varargin{6} > 0
            spec.framesUntilTransition = varargin{6};
        elseif ischar(varargin{6}) && strcmp(varargin{6},'msPenalty') % also allow this flag to get value from reinforcementMgr
            spec.framesUntilTransition = varargin{6};
        elseif isempty(varargin{6})
            spec.framesUntilTransition = [];
        else
            error('framesUntilGrad must be a real scalar or empty')
        end
        % stochasticDistribution
        if iscell(varargin{7})
                stoD = varargin{7};
                if isreal(stoD{1}) && stoD{1} >= 0 && stoD{1} < 1 && isvector(stoD{2})
                    spec.stochasticDistribution = varargin{7};
                else
                    error('distribution must be a real number in [0,1) and port must be a vector');
                end
        elseif isempty(varargin{7})
            'do nothing here b/c we do not want any auto requests';
        else
            error('stochasticDistribution must be a cell array');
        end
        % isFinalPhase
        if isscalar(varargin{8}) && (varargin{8} == 0 || varargin{8} == 1)
            spec.isFinalPhase = varargin{8};
        else
            error('isFinalPhase must be a scalar 0 or 1')
        end
        
        % this stays at the bottom of case 6 - out of the input arg parsing
        spec = class(spec,'stimSpec');
        
    otherwise
        error('Wrong number of input arguments')
end

