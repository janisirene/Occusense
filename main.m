%% entry point for testing
% simulate video from given labelled data
% run background subtraction algorithm
% play / write videos at the end
doWrite = true; % write videos or not

% parameters for simulation
minFrames = 500;
pr = 0.3; % probability of motion (smaller is easier)

rng(2);
[v, events, peopleCount, isBackground] = simulateLongVideo(minFrames, pr);
% load('exampleSimulation.mat');
% v = readOccusenseVideo('OccusenseData/WeirdData/runoutandin');
% isBackground = true(size(v, 3), 1);
% isBackground(20:23) = false;
% isBackground(39:41) = false;
% events = [20, -1; 39, 1];
% peopleCount = 0;

% v = readOccusenseVideo('OccusenseData/WeirdData/lingerThroughOut');
% isBackground = true(size(v, 3), 1);
% isBackground(31:71) = false;
% events = [31, -1];
% peopleCount = -1;

% v = readOccusenseVideo('OccusenseData/WeirdData/twoquickout');
% isBackground = true(size(v, 3), 1);
% isBackground(35:51) = false;
% isBackground(68:76) = false;
% isBackground(84:90) = false;
% events = [35, -2; 68, 1; 84, 1];
% peopleCount = 0;

% v = readOccusenseVideo('OccusenseData/TWO/OUT/two_out.txt');
% isBackground = true(size(v, 3), 1);
% isBackground(26:30) = false;
% isBackground(34:37) = false;
% events = [26, -1; 34, -1];
% peopleCount = -2;
doPlot = false;
%% background subtraction - adaptive foreground detection
backsubParams = struct(...
    'nBackgroundFrames', 20,...     % background history
    'sigma', 0.5,...                % standard deviation of gaussian kernel
    'neighborhoodOrder', 1,...      % spatial neighborhoods
    'nIterations', 3,...            % number of iterations per frame for labelling
    'gamma', .5,...                  % control influence of MRF model
    'doPlot', false);               % plot or not

backsubParams2 = struct(...
    'nBackgroundFrames', 20,...     % background history
    'threshold', 2.5,...
    'neighborhoodOrder', 1,...
    'nIterations', 3,...
    'gamma', 1,...
    'rho', .3);

% returns a binary mask that is the same size as the original video (1 for
% foreground, 0 for background)
foreground = backgroundSubtraction(v, backsubParams);
%out = backgroundSubtractionSimple(v, backsubParams2);

%% optical flow
% find foreground variables
indices = find(foreground == 0);
new_v = v;
new_v(indices) = 0;

% optical flow using foreground only
[I_y, I_y_avg, I_t, v_y, v_y_avg_all] = opticalflow(new_v);

%[I_y, I_y_avg, I_t, v_y, v_y_avg_all] = opticalflow(out);

%% people counter
[pc,startstopdir] = pCounter(I_y_avg,foreground, 0);

%% things for plotting
if doPlot
    mmv = squeeze(mean(mean(v, 1), 2));
    yl = round([min(mmv)-1, max(mmv) + 1]);
    groundTruth = struct('isBackground', isBackground, 'events', events,...
        'frameMeans', mmv);
    computed = struct('foreground', foreground, 'frameFeature',...
        squeeze(sum(sum(foreground, 1), 2)));
    comOF = struct('foreground', foreground, 'frameFeature',...
        v_y_avg_all);
    %% play the original video
    
    playVideo(v, [], groundTruth);
    
    %% play the video (with background subtraction output)
    
    playVideo(v, [], groundTruth, computed);
    
    %% play the direction video
    
    playVideo(v, [], groundTruth, comOF);
    
    %% plot results of person detection
    figure(100); clf; set(gcf, 'Color', 'w');
    subplot(2, 1, 1); hold on;
    pcolor(1:size(v, 3), yl(1):yl(2), repmat(0+isBackground', [diff(yl)+1, 1]));
    shading flat; caxis([-2 1]); colormap gray;
    plot(1:length(mmv), mmv, 'b', 'linewidth', 2);
    xlim([1, length(mmv)]);
    xlabel('time index'); ylabel('temperature');
    title('mean frame temperature');
    for ei = 1:size(events, 1)
        text(events(ei, 1)+1, yl(1) + .85 * diff(yl), num2str(events(ei, 2)),...
            'FontSize', 16, 'FontWeight', 'bold');
    end
    set(gca, 'FontSize', 14, 'FontWeight', 'bold');
    ylim(yl);
    
    subplot(2, 1, 2); hold on;
    yl2 = [0, 40];
    pcolor(1:size(v, 3), yl2(1):yl2(2), repmat(0+isBackground', [diff(yl2)+1, 1]));
    shading flat; caxis([-2 1]); colormap gray;
    plot( 1:length(mmv), squeeze(sum(sum(foreground, 1), 2)), 'b', 'linewidth', 2);
    xlim([1, length(mmv)]);
    xlabel('time index'); ylabel('#');
    title('number of detected foreground pixels');
    set(gca, 'FontSize', 14, 'FontWeight', 'bold');
end