% data exploration script

ptToData = 'OccusenseData';

condition = 'OUT';

dr = dir(fullfile(ptToData, condition, '*.txt'));

i = randi(length(dr)); % randomly choose a video from this folder to look at
fname = fullfile(ptToData, condition, dr(i).name);

v = readOccusenseVideo(fname);

%% look at max heat in each row
sy = '*os^';
maxHeatRow = squeeze(max(v, [], 2));
figure(); clf; hold on;
for j = 1:4
    plot(1:size(v, 3), maxHeatRow(j, :), [sy(j), '-'], 'markersize', 10, 'linewidth', 2);
end
xlabel('time index');
ylabel('max temperature');
legend('1st row', '2nd row', '3rd row', '4th row');
title(sprintf('%s: %s', condition, dr(i).name));
set(gca, 'FontSize', 14, 'FontWeight', 'bold');
set(gcf, 'Color', 'w');