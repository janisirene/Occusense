% test people counter on number of events
backsubParams1 = struct(...
    'nBackgroundFrames', 20,...     % background history
    'sigma', 0.5,...                % standard deviation of gaussian kernel
    'neighborhoodOrder', 1,...      % spatial neighborhoods
    'nIterations', 3,...            % number of iterations per frame for labelling
    'gamma', 0.2,...                  % control influence of MRF model
    'doPlot', false);               % plot or not
thr = 0;
nSim = 50;
nEvents = 10;

pcCounts = cell(nEvents, 1);
for e = 1:nEvents
    pcCounts{e} = nan(nSim, 2);
    for i = 1:nSim
        rng(i);
        [v, events, peopleCount, isBackground] = simulateLongVideo(2000, .3, e);
        
        %% background subtraction methods
        foreground = backgroundSubtraction(v, backsubParams1);
        
        %% optical flow
        % find foreground variables
        indices = find(foreground == 0);
        new_v = v;
        new_v(indices) = 0;
        
        
        % optical flow using foreground only
        [I_y1, I_y_avg1, I_t1, v_y1, v_y_avg_all1] = opticalflow(new_v);
        [pc1,startstopdir1] = pCounter(I_y_avg1,foreground, 0);
        
        pcCounts{e}(i, :) = [pc1, peopleCount];
    end
end

%% error integration
errs = cellfun(@(x) diff(x, [], 2), pcCounts, 'Uniformoutput', false);
errs = cat(2, errs{:});

merr = mean(errs, 1);
sderr = std(errs, 1);

figure(1); clf;
[hl, hp] = boundedline(1:nEvents, merr, sderr, 'b');
set(hl, 'LineWidth', 2, 'marker', '.', 'markersize', 20);
standardPlot;
xlabel('number of motion events');
ylabel('mean +- std');
title('people count error');
xlim([1, nEvents]);