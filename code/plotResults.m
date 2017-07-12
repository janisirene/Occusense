% plot all results
%dr1 = dir('abs*.mat');
%dr2 = dir('bs*.mat');

dr1(1) = struct('name', 'abs_gamma0.20_sigma0.50_eta1.mat');
dr1(2).name = 'abs_gamma0.50.mat';
dr1(3).name = 'abs_gamma0.80.mat';
dr1(4).name =  'abs_gamma0.50_sigma0.50_eta1_2.mat';

dr2(1) = struct('name', 'bs_gamma2.00_rho0.01_thr2.00.mat');
dr2(2).name = 'bs_gamma2.00_rho0.01_thr2.50_2.mat';
dr2(3).name = 'bs_gamma1.00_rho0.10_thr2.50.mat';
dr2(4).name = 'bs_gammaInf_rho0.01_thr2.50.mat';

sy = '*oxs^v.';
lsty = {'-', ':', '--', '-.'};

figure(1); clf;% ROC curves
figure(2); clf; hold on; % classifier performance
plot(-1, -1, 'b-', 'linewidth', 2);
plot(-1, -1, 'r-', 'linewidth', 2);

for i = 1:length(dr1)
    load(dr1(i).name);
    figure(1); hold on;
    plot(sqrt(1-roc(:, 2)), roc(:, 1), [sy(rem(i, length(sy))+1), '-'], 'linewidth', 2,...
        'Color', 'b',...
        'markersize', 10, 'linestyle', lsty{rem(i, length(lsty))+1});
    
    figure(2);
    plot(pccorr / pctotals, [sy(rem(i, length(sy))+1), '-'], 'linewidth', 2,...
        'Color',  'b',...
        'markersize', 10, 'linestyle', lsty{rem(i, length(lsty))+1});
    
    if i <= length(dr2)
        load(dr2(i).name);
        figure(1);
        if i == length(dr2)
            shift = .1; 
        else 
            shift = 0;
        end
        plot(sqrt(1-roc(:, 2)) - shift, roc(:, 1), [sy(rem(i, length(sy))+1), '-'], 'linewidth', 2,...
            'Color', 'r',...
            'markersize', 10, 'linestyle', lsty{rem(i, length(lsty))+1});
        
        figure(2);
        plot(pccorr / pctotals, [sy(rem(i, length(sy))+1), '-'], 'linewidth', 2,...
            'Color', 'r',...
            'markersize', 10, 'linestyle', lsty{rem(i, length(lsty))+1});
    end
end

%%
figure(1);
xlim(sqrt([0, .01])); ylim([0.2, 1]);
set(gca, 'XTick', sqrt([0, .001, .004, .01]),...
    'XTickLabel', [0, .001,  .004, .01], 'YTick', [.2:.2:1]);
ylabel('hit rate (on motion events)');
ylim([0.2, 1]);
% legend('foreground-adaptive', 'background subtraction', 'Location', 'southeast');
xlabel('false positive rate (on individual frames)');
set(gca, 'FontSize', 20, 'FontWeight', 'bold');
title('Foreground Detection: ROC curves');
print('-f1', 'roc', '-dpng');

figure(2);
xlim([0, 7]); ylim([0.2, 1]);
% legend('motion detection', 'background subtraction', 'Location', 'southeast');
xlabel('threshold INDEX');
ylabel('proportion correct');
title('direction classification');
set(gca, 'FontSize', 20, 'FontWeight', 'bold');
print('-f2', 'directionClassification', '-dpng');

%% people counter error histogram
load('TestResults/abs_gamma0.20_sigma0.50_eta1.mat');
thridx = 4;
tpc = peopleCounts1(:, end);
pce = (tpc - peopleCounts1(:, thridx));
figure(3); clf;
hist(pce);