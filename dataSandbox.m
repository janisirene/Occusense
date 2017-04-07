% data exploration script

ptToData = 'OccusenseData\IN';

condition = 'IN';

dr = dir(fullfile(ptToData, condition, '*.txt'));

i = randi(length(dr)); % randomly choose a video from this folder to look at
fname = fullfile(ptToData, condition, dr(i).name);

v = readOccusenseVideo(fname);

%% look at max heat in each row
maxHeatRow = squeeze(max(v, [], 2));
figure(); clf; hold on;
plot(1:size(v, 3), maxHeatRow, '.-', 'markersize', 10, 'linewidth', 2);
xlabel('time index');
ylabel('max temperature');
legend('1st row', '2nd row', '3rd row', '4th row');
title(sprintf('%s: %s', condition, dr(i).name));
set(gca, 'FontSize', 14, 'FontWeight', 'bold');
set(gcf, 'Color', 'w');