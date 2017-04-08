%% entry point for testing
minFrames = 500;
pr = 0.3; % probability of motion (smaller is easier)

%[v, events, peopleCount, isBackground] = simulateLongVideo(minFrames, pr);
load('exampleSimulation.mat');

%% play the video
figure(1); clf;
subplot(2, 1, 1);
himg = imshow(v(:, :, 1), [20, 30]);

subplot(2, 1, 2); hold on;
hMn = plot(squeeze(mean(mean(v, 1), 2)));
yl = ylim;
hVert = plot([0, 0], yl, 'y-', 'linewidth', 2);
for ei = 1:size(events, 1)
    plot(events(ei, 1) * [1, 1], yl, 'r:')
    text(events(ei, 1)+1, yl(1) + .75 * diff(yl), num2str(events(ei, 2)),...
        'FontSize', 14);
end
xlim([0, size(v, 3)]);

for ti = 1:size(v, 3)
    set(himg, 'CData', v(:, :, ti));
    set(hVert, 'XData', [ti, ti]);
    pause(0.1);
end