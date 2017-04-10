%% entry point for testing
% simulate video from given labelled data
% run background subtraction algorithm
% play / write videos at the end
doWrite = false; % write videos or not

% parameters for simulation
minFrames = 500;
pr = 0.3; % probability of motion (smaller is easier)

[v, events, peopleCount, isBackground] = simulateLongVideo(minFrames, pr);
% load('exampleSimulation.mat');

%% background subtraction
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

%% play the video
figure(1); clf; set(gcf, 'Color', 'w');
subplot(2, 1, 1);
himg = imshow(v(:, :, 1), [20, 30]);

subplot(2, 1, 2); hold on;
mmv = squeeze(mean(mean(v, 1), 2));
yl = round([min(mmv)-1, max(mmv) + 1]);
pcolor(1:size(v, 3), yl(1):yl(2), repmat(0+isBackground', [diff(yl)+1, 1]));
shading flat; caxis([-2 1]); colormap gray;
hMn = plot(mmv, 'b');
hVert = plot([0, 0], yl, 'r-', 'linewidth', 2);
for ei = 1:size(events, 1)
    text(events(ei, 1)+1, yl(1) + .75 * diff(yl), num2str(events(ei, 2)),...
        'FontSize', 14);
end
xlim([0, size(v, 3)]);
xlabel('time index');
title('mean frame temperature');
ylim(yl);

if doWrite, vw = VideoWriter('exampleVideo.avi'); open(vw); end
for ti = 1:size(v, 3)
    set(himg, 'CData', v(:, :, ti));
    set(hVert, 'XData', [ti, ti]);
    if doWrite, writeVideo(vw, getframe(1));end
    pause(0.1);
end
if doWrite, close(vw); end

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

%% play the video (with background subtraction output)
figure(2); clf; set(gcf, 'Color', 'w');
subplot(2, 1, 1); hold on;
himg = imshow(v(:, :, 1), [20, 30]);
hDots = plot(0, 0, 'r.', 'markersize', 20);

subplot(2, 1, 2); hold on;
yl = [22, 27];
mmv = squeeze(mean(mean(v, 1), 2));
ax1 = gca;
pcolor(1:size(v, 3), yl(1):yl(2), repmat(0+isBackground', [diff(yl)+1, 1]));
shading flat; caxis([-2 1]); colormap gray;
[hAx, hMn, hN] = plotyy(1:length(mmv), mmv,...
    1:length(mmv), squeeze(sum(sum(foreground, 1), 2)));
hVert = plot(hAx(1), [0, 0], yl, 'r-', 'linewidth', 2);
for ei = 1:size(events, 1)
    text(events(ei, 1)+1, yl(1) + .75 * diff(yl), num2str(events(ei, 2)),...
        'FontSize', 14);
end
xlim([0, size(v, 3)]);
xlabel('time index');
title('mean frame temperature');
set([ax1, hAx(1)], 'YLim', yl);
set([ax1, hAx], 'XLim', [1, length(mmv)]);
set(hMn, 'Color', 'b');
set(hAx(1), 'YTick', yl(1):yl(2));
ylabel(hAx(1), 'mean frame temp');
ylabel(hAx(2), '# detected foreground pixels');

if doWrite, vw = VideoWriter('exampleVideoBS.avi'); open(vw); end
for ti = 1:size(v, 3)
    [r, c] = find(foreground(:, :, ti));
    set(hDots, 'XData', c, 'YData', r);
    set(himg, 'CData', v(:, :, ti));
    set(hVert, 'XData', [ti, ti]);
    if doWrite, writeVideo(vw, getframe(2));end
    pause(0.1);
end
if doWrite, close(vw); end