function playVideo(v, params, groundTruth, computed)
[h, w, nFrames] = size(v);

if ~exist('params', 'var') || ~isempty(params)
     clim = params.clim;
     doWrite = params.doWrite;
else
    clim = quantile(v(:), [.05, .95]);
    doWrite = false;
end

% ground truth parameters if you have them
if exist('groundTruth', 'var')
    isBackground = groundTruth.isBackground;
    events = groundTruth.events;
    mmv = groundTruth.frameMeans;
    yl = [min(mmv), max(mmv)];
else
    isBackground = true(nFrames, 1);
    events = [];
    mmv = [];
end

% foreground if you have it
if exist('computed', 'var')
    foreground = computed.foreground;
    foreFeature = computed.frameFeature;
else
    foreground = [];
    foreFeature = squeeze(mean(mean(v, 1), 2));
end


figure(123); clf; set(gcf, 'Color', 'w');
subplot(2, 1, 1); hold on;
himg = imshow(v(:, :, 1), clim);
hDots = plot(-1, -1, 'r.', 'markersize', 20);
xlim([1, w]); ylim([1, h]);

subplot(2, 1, 2); hold on;
ax1 = gca;
pcolor(1:size(v, 3), floor(yl(1)):ceil(yl(2)), ...
    repmat(0+isBackground', [ceil(yl(2)) - floor(yl(1))+1, 1]));
shading flat; caxis([-2 1]); colormap gray;
[hAx, hMn, hN] = plotyy(1:length(mmv), mmv,...
    1:length(mmv), foreFeature);
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
set(hAx(1), 'YTick', floor(yl(1)):ceil(yl(2)));
ylabel(hAx(1), 'mean frame temp');
ylabel(hAx(2), 'computed frame feature');

if doWrite, vw = VideoWriter('tempName.avi'); open(vw); end

for ti = 1:size(v, 3)
    if ~isempty(foreground)
        [r, c] = find(foreground(:, :, ti));
        set(hDots, 'XData', c, 'YData', r);
    end
    set(himg, 'CData', v(:, :, ti));
    set(hVert, 'XData', [ti, ti]);
    if doWrite, writeVideo(vw, getframe(2));end
    pause(0.1);
end
if doWrite, close(vw); end
end