% parameters for simulation
clear all; clc;
minFrames = 1000;
pr = 0.3; % probability of motion (smaller is easier)

backsubParams1 = struct(...
    'nBackgroundFrames', 20,...     % background history
    'sigma', 0.5,...                % standard deviation of gaussian kernel
    'neighborhoodOrder', 1,...      % spatial neighborhoods
    'nIterations', 3,...            % number of iterations per frame for labelling
    'gamma', 0.5,...                  % control influence of MRF model
    'doPlot', false);               % plot or not

backsubParams2 = struct(...
    'nBackgroundFrames', 20,...     % background history
    'threshold', 2.5,...
    'neighborhoodOrder', 1,...
    'nIterations', 3,...
    'gamma', 1.5,...
    'rho', .01);

nSimulations = 1;
testThrs = [0:5; 0:5]';

totals = [0, 0]; % total fore and backgrounds
correct1 = zeros(size(testThrs)); % hits and correct rejections
correct2 = zeros(size(testThrs));
peopleCounts1 = nan(nSimulations, size(testThrs, 1)+1);
peopleCounts2 = nan(nSimulations, size(testThrs, 1)+1);
pcCorrect = zeros(size(testThrs));
pctotals = 0;
for i = 1:nSimulations
    rng(i);
    [v, events, peopleCount, isBackground] = simulateLongVideo(minFrames, pr);
    [si, ei] = getIndicesFromBin(~isBackground);
    
    %% background subtraction methods
    foreground = backgroundSubtraction(v, backsubParams1);
    nPixels = squeeze(sum(sum(foreground, 1), 2));
    
%     out = backgroundSubtractionSimple(v, backsubParams2);
%     mmv = squeeze(sum(sum(out, 1), 2));
    
    %% optical flow
    % find foreground variables
    indices = find(foreground == 0);
    new_v = v;
    new_v(indices) = 0;
    
%     new_v2 = v;
%     new_v2(~out) = 0;
    
    
    % optical flow using foreground only
    [I_y1, I_y_avg1, I_t1, v_y1, v_y_avg_all1] = opticalflow(v);
%     [I_y2, I_y_avg2, I_t2, v_y2, v_y_avg_all2] = opticalflow(v);
    
    
    %% testing stuff
    totals(1) = totals(1) + length(si);
    totals(2) = totals(2) + sum(isBackground);
    
    
    %{
    figure(i); clf; hold on;
    imagesc(repmat(0+isBackground', [10, 1]));
    ylim([1, 10]); caxis([-2, 1]); colormap gray;
    ax0 = gca;
    ax1 = axes('Position', get(gca, 'Position'));
    plot(squeeze(mean(mean(v, 1), 2)), 'k', 'linewidth', 2);
    ax2 = axes('Position', get(gca, 'Position'));
    plot(nPixels, 'b', 'linewidth', 2);
    lineThrough(testThrs(3, 1), 'b');
    ax3 = axes('Position', get(gca, 'Position'));
    plot(mmv, 'r', 'linewidth', 2);
    lineThrough(testThrs(3, 2), 'r');
    set([ax1, ax2, ax3], 'Color', 'none');
    set([ax0, ax1, ax2, ax3], 'XLim', [1, size(v, 3)],...
        'Visible', 'off');
    set(ax1, 'Visible', 'on');
    %}
    peopleCounts1(i, end) = peopleCount;
    peopleCounts2(i, end) = peopleCount;
    pctotals = pctotals + length(events);
    for tt = 1:size(testThrs, 1)
        %% people counting part
        %         [pc1, dirs1, event1, ind1] = peopleCounter(foreground, v_y_avg_all1, testThrs(tt, 1));
        %         peopleCounts1(i, tt) = pc1;
        %         [pc2, dirs2, event2, ind2] = peopleCounter(mmv, v_y_avg_all2, testThrs(tt, 2));
        %         peopleCounts2(i, tt) = pc2;
        [pc1,startstopdir1] = pCounter(I_y_avg1,foreground, testThrs(tt, 1));
%         [pc2,startstopdir2] = pCounter(I_y_avg2,out, testThrs(tt, 2));
        
        peopleCounts1(i, tt) = pc1;
%         peopleCounts2(i, tt) = pc2;
        
        isFore1 = nPixels > testThrs(tt, 1);
%         isFore2 = mmv > testThrs(tt, 2);
        
%         for jj = 2:length(isFore1)-1 % kill single frame events
%             isFore1(jj) = isFore1(jj) & (isFore1(jj-1) | isFore1(jj+1));
%             isFore2(jj) = isFore2(jj) & (isFore2(jj-1) | isFore2(jj+1));
%         end
        
        for ii = 1:length(si)
            % total number of events?
            cnt1 = sum(isFore1(si(ii):ei(ii)));
%             cnt2 = sum(isFore2(si(ii):ei(ii)));

            if cnt1 < (ei(ii) - si(ii))/4
               keyboard; 
            end
            
            % was the event picked up?
            correct1(tt, 1) = correct1(tt, 1) + (cnt1 > (ei(ii)-si(ii))/4);
%             correct2(tt, 1) = correct2(tt, 1) + (cnt2 > (ei(ii)-si(ii))/4);
        end
        
        % check whether direction was correctly classified
        for ee = 1:size(events, 1)
            if ~isempty(startstopdir1)
                [d1, mi1] = sort(abs(events(ee, 1) - startstopdir1(:, 1)));
            else
                d1 = [];
            end
%             if ~isempty(startstopdir2)
%                 [d2, mi2] = sort(abs(events(ee, 1) - startstopdir2(:, 1)));
%             else
%                 d2 = [];
%             end
            
            nPeople = abs(events(ee, 2));
            
            for nn = 1:nPeople
                trueDir = sign(events(ee, 2));
                if length(d1) >= nn && d1(nn) < 10
                    myDir = startstopdir1(mi1(nn), 3);
                    if myDir == trueDir % correct
                        pcCorrect(tt, 1) = pcCorrect(tt, 1) + 1;
                        
                    end
                    
                end
%                 if length(d2) >= nn && d2(nn) < 10
%                     
%                     myDir = startstopdir2(mi2(nn), 3);
%                     if myDir == trueDir % correct
%                         pcCorrect(tt, 2) = pcCorrect(tt, 2) + 1;
%                     end
%                 end
            end
            
        end
        
        correct1(tt, 2) = correct1(tt, 2) + sum(isBackground & ~isFore1);
%         correct2(tt, 2) = correct2(tt, 2) + sum(isBackground & ~isFore2);
    end
    
end

%%
roc1 = bsxfun(@rdivide, correct1, totals);
roc2 = bsxfun(@rdivide, correct2, totals);
roc = roc1;
thrs = testThrs(:, 1);
pccorr = pcCorrect(:, 1);
sname = sprintf('abs_gamma%1.2f_sigma%1.2f_eta%i_2.mat', backsubParams1.gamma, backsubParams1.sigma, backsubParams1.neighborhoodOrder);
save(sname, 'roc', 'thrs', 'pccorr', 'backsubParams1', 'pctotals', 'peopleCounts1');

roc = roc2;
thrs = testThrs(:, 2);
pccorr = pcCorrect(:, 2);
sname = sprintf('bs_gamma%1.2f_rho%1.2f_thr%1.2f_2.mat', backsubParams2.gamma,...
    backsubParams2.rho, backsubParams2.threshold);
save(sname, 'roc', 'thrs', 'pccorr', 'backsubParams2', 'pctotals', 'peopleCounts2');

%% ROC curve for event detection


figure(100); clf; hold on; set(gcf, 'Color', 'w');
plot(1-roc1(:, 2), roc1(:, 1), 'bo-', 'markersize', 10, 'linewidth', 2);
plot(1-roc2(:, 2), roc2(:, 1), 'r.-', 'markersize', 20, 'linewidth', 2);
xlabel('false positive rate');
ylabel('true positive rate');
title('ROC curve');
set(gca, 'FontSize', 20, 'FontWeight', 'bold');
legend('foreground detection', 'background subtraction',...
    'Location', 'southeast');

%% performance in direction classification
figure(101); clf; hold on; set(gcf, 'Color', 'w');
plot(1:size(testThrs, 1), pcCorrect(:, 1) / pctotals, 'b.-', 'markersize', 20, 'linewidth', 2);
plot(1:size(testThrs, 1), pcCorrect(:, 2) / pctotals, 'r.-', 'markersize', 20, 'linewidth', 2);