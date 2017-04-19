%% entry point for testing
% simulate video from given labelled data
% run background subtraction algorithm
% play / write videos at the end
doWrite = false; % write videos or not

% parameters for simulation
minFrames = 500;
pr = 0.3; % probability of motion (smaller is easier)

% [v, events, peopleCount, isBackground] = simulateLongVideo(minFrames, pr);
load('exampleSimulation.mat');

%% background subtraction - adaptive foreground detection
backsubParams = struct(...
    'nBackgroundFrames', 20,...     % background history
    'sigma', 0.5,...                % standard deviation of gaussian kernel
    'neighborhoodOrder', 1,...      % spatial neighborhoods
    'nIterations', 3,...            % number of iterations per frame for labelling
    'gamma', 1,...                  % control influence of MRF model
    'doPlot', false);               % plot or not

% returns a binary mask that is the same size as the original video (1 for
% foreground, 0 for background)
foreground = backgroundSubtraction(v, backsubParams);

%% optical flow
% find foreground variables
indices = find(foreground == 0);
new_v = v;
new_v(indices) = 0;

% optical flow using foreground only
[v_y, v_y_avg, v_y_avg_all] = opticalflow(new_v);

%% things for plotting
mmv = squeeze(mean(mean(v, 1), 2));
yl = round([min(mmv)-1, max(mmv) + 1]);

%% play the original video
groundTruth = struct('isBackground', isBackground, 'events', events,...
    'frameMeans', mmv);
playVideo(v, [], groundTruth);

%% play the video (with background subtraction output)
computed = struct('foreground', foreground, 'frameFeature',...
    squeeze(sum(sum(foreground, 1), 2)));
playVideo(v, [], groundTruth, computed);

%% play the direction video
comOF = struct('foreground', foreground, 'frameFeature',...
    -v_y_avg_all);
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

subplot(2, 1, 2); hold on;
yl2 = [0, 40];
pcolor(1:size(v, 3), yl2(1):yl2(2), repmat(0+isBackground', [diff(yl2)+1, 1]));
shading flat; caxis([-2 1]); colormap gray;
plot( 1:length(mmv), squeeze(sum(sum(foreground, 1), 2)), 'b', 'linewidth', 2);
xlim([1, length(mmv)]);
xlabel('time index'); ylabel('#');
title('number of detected foreground pixels');
set(gca, 'FontSize', 14, 'FontWeight', 'bold');
