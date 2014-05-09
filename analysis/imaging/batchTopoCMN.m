clear all

pathname = 'C:\data\imaging\';

n=1;

files(n).subj = 'g2b7lt';
files(n).expt = '022514';
files(n).topox =  '022514 G62B.7-LT HvV_center Behavior\topoXmaps.mat'; 
files(n).topoy = '022514 G62B.7-LT HvV_center Behavior\topoYmaps.mat';
files(n).behav = '022514 G62B.7-LT HvV_center Behavior\022514 g62b7lt behav data.mat';
files(n).grating = '';
files(n).loom = '';
files(n).monitor = 'vert';
files(n).task = 'HvV_center';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';

n=n+1;

files(n).subj = 'g62hltt';
files(n).expt = '042414';
files(n).topox =  '042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run1_topox_fstop5.6_exp50msmaps.mat'; 
files(n).topoy = '042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run2_topoy_fstop5.6_exp50msmaps.mat';
files(n).behav = '';
files(n).grating = '042414g62h1tt passive mapping\G62H1TT_run3_gratingsSFTF_fstop5.6_exp50ms\G62H1TT_run3_gratingsSFTF_fstop5.6_exp50msmaps.mat';
files(n).loom = '042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run4_looming_fstop5.6_exp50msmaps.mat';
files(n).monitor = 'vert';
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';


% %     {'042414g62hltt vert'...
% %     '042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run1_topox_fstop5.6_exp50msmaps.mat' ...
% %     '042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run2_topoy_fstop5.6_exp50msmaps.mat'...
% %     ''...
% %    '042414g62h1tt passive mapping\G62H1TT_run3_gratingsSFTF_fstop5.6_exp50ms\G62H1TT_run3_gratingsSFTF_fstop5.6_exp50msmaps.mat'...
% %    '042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run4_looming_fstop5.6_exp50msmaps.mat' ...
% %    }


% files = { ...
% 
%     
%     {'022514 G62B7-LT' ...
%     '022514 G62B.7-LT HvV_center Behavior\topoXmaps.mat' ...
%     '022514 G62B.7-LT HvV_center Behavior\topoYmaps.mat' ...
%     '022514 G62B.7-LT HvV_center Behavior\022514 g62b7lt behav data.mat'
%     }
% %     
% %         {'022314 G62B7-LT' ...
% %     '022314 G62B.7-LT HvV_center Behavior\022314 G62B.7-LT passive veiwing\G62B.7-LT_run2_topoX_15ms\topox_dfofmaps.mat' ...
% %     '022314 G62B.7-LT HvV_center Behavior\022314 G62B.7-LT passive veiwing\G62B.7-LT_run3_topoY_15ms\g62b4ln_topoymaps.mat' ...
% %     ''
% %     }
% %     
% %     
%     {'042214 j140 lp horiz' ...
%     '042214 j140 gc6 in lp\J140_run3_topoY_50ms_exp_landscape_fs2.8maps.mat'...
%     '042214 j140 gc6 in lp\J140_run2_topoX_50ms_exp_landscape_fs2.8maps.mat' ...
%     ''
%     }
%     

%     
% %     {'042414g62hltt horiz'...
% %     '042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run6_topoy_landscape_fstop5.6_exp50msmaps.mat' ...
% %     '042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run5_topox_landscape_fstop5.6_exp50msmaps.mat'...
% %     }
% %     
% %     {'022814 G62B3'...
% %     '022814 G62B.3-RT HvV Behavior\topoXmaps.mat' ...
% %      '022814 G62B.3-RT HvV Behavior\topoYmaps.mat' ...
% %      }
% %     
% %      {'030114 G62B5-LT' ...
% %      '030114 G62B.5-LT GTS Behavior (Fstop 8)\topoXf8maps.mat' ...
% %      '030114 G62B.5-LT GTS Behavior (Fstop 8)\topoYf8maps.mat' ...
% %      }
%      
%     }
outpathname = 'C:\data\imaging\widefield compilation\'

for f = 1:length(files)
getRegions(files(f),pathname,outpathname);
end

for f = 1:length(files)
overlayMaps(files(f),pathname,outpathname);
end
for f = 1:length(files)
fourPhaseOverlay(files(f),pathname,outpathname,'loom');
end
for f = 1:length(files)
fourPhaseOverlay(files(f),pathname,outpathname,'grating');
end