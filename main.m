function [] = main()

if ~isdeployed
    disp('loading path')
    %for IU HPC
    addpath(genpath('/N/u/brlife/git/vistasoft'))
    addpath(genpath('/N/u/brlife/git/jsonlab'))

    %for old VM
    addpath(genpath('/usr/local/vistasoft'))
    addpath(genpath('/usr/local/jsonlab'))
end

% Set top directory
topdir = pwd;

% Load configuration file
config = loadjson('config.json');

% load classification file
load(fullfile(config.classification));

%% Save output
save(fullfile('wmc','classification.mat'),'classification','fg_classified');

mkdir(fullfile('wmc','tracts'));

% Create structure to generate colors for each tract
tracts = fg2Array(fg_classified);

% Make colors for the tracts
%cm = parula(length(tracts));
cm = distinguishable_colors(length(tracts));
for it = 1:length(tracts)
   tract.name   = strrep(tracts{it}.name, '_', ' ');
   all_tracts(it).name = strrep(tracts{it}.name, '_', ' ');
   all_tracts(it).color = cm(it,:);
   tract.color  = cm(it,:);

   %tract.coords = tracts(it).fibers;
   %pick randomly up to 1000 fibers (pick all if there are less than 1000)
   %fiber_count = min(1000, numel(tracts{it}.fibers));
   %tract.coords = tracts{it}.fibers(randperm(fiber_count)); 
   tract.coords = tracts{it}.fibers; 
   savejson('', tract, fullfile('wmc','tracts',sprintf('%i.json',it)));
   all_tracts(it).filename = sprintf('%i.json',it);
   clear tract
end

% Save json outputs
savejson('', all_tracts, fullfile('wmc/tracts/tracts.json'));

% Create and write output_fibercounts.txt file
for i = 1 : length(fg_classified)
    name = fg_classified{i}.name;
    num_fibers = length(fg_classified{i}.fibers);
    
    fibercounts(i) = num_fibers;
    tract_info{i,1} = name;
    tract_info{i,2} = num_fibers;
end

T = cell2table(tract_info);
T.Properties.VariableNames = {'Tracts', 'FiberCount'};

writetable(T, fullfile('wmc','output_fibercounts.txt'));

exit;
end


