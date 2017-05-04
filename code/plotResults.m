% plot all results
dr1 = dir('abs*.mat');
dr2 = dir('bs*.mat');

sy = '*oxs^v.';

figure(1); clf; hold on; % ROC curves
plot(-1, -1, 'b-', 'linewidth', 2);
plot(-1, -1, 'r-', 'linewidth', 2);
figure(2); clf; hold on; % classifier performance
plot(-1, -1, 'b-', 'linewidth', 2);
plot(-1, -1, 'r-', 'linewidth', 2);

for i = 1:length(dr1)
    load(dr1(i).name);
    figure(1);
    plot(1-roc(:, 2), roc(:, 1), [sy(i), '-'], 'linewidth', 2,...
        'Color', [0 0 0.3 + 0.7 * i / length(dr1)],...
        'markersize', 10);
    
    figure(2);
    plot(pccorr / pctotals, [sy(i), '-'], 'linewidth', 2,...
        'Color',  [0 0 0.3 + 0.7 * i / length(dr1)],...
        'markersize', 10);
    
    if i <= length(dr2)
        load(dr2(i).name);
        figure(1);
        plot(1-roc(:, 2), roc(:, 1), [sy(i), '-'], 'linewidth', 2,...
            'Color', [0.3 + 0.7 * i / length(dr1)  0 0],...
            'markersize', 10);
        
        figure(2);
        plot(pccorr / pctotals, [sy(i), '-'], 'linewidth', 2,...
            'Color', [0.3 + 0.7 * i / length(dr1) 0 0],...
            'markersize', 10);
    end
end

figure(1);
xlim([0, 1]); ylim([0.2, 1]);
legend('foreground-adaptive', 'background subtraction', 'Location', 'southeast');
xlabel('false positive rate (on individual frames)');
ylabel('hit rate (on motion events)');
set(gca, 'FontSize', 20, 'FontWeight', 'bold');
title('Foreground Detection: ROC curves');
print('-f1', 'roc', '-dpng');

figure(2);
xlim([0, 7]); ylim([0.2, 1]);
legend('motion detection', 'background subtraction', 'Location', 'southeast');
xlabel('threshold INDEX');
ylabel('performance');
title('direction classification');
set(gca, 'FontSize', 20, 'FontWeight', 'bold');
print('-f2', 'directionClassification', '-dpng');