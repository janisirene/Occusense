close all;
clearvars;

load('exampleSimulation.mat');

% background subtraction
backsubParams = struct(...
    'nBackgroundFrames', 20,...     % background history
    'sigma', 0.5,...                % standard deviation of gaussian kernel
    'neighborhoodOrder', 1,...      % spatial neighborhoods
    'nIterations', 3,...            % number of iterations per frame for labelling
    'gamma', 1,...                  % control influence of MRF model
    'doPlot', false);               % plot or not

[l,m,n] = size(v);
foreground = backgroundSubtraction(v, backsubParams);

% find foreground variables
indices = find(foreground == 0);
new_v = v;
new_v(indices) = 0;

% optical flow using foreground only
[I_y, I_y_avg, I_t, v_y, v_y_avg_all] = opticalflow(new_v);

[pc,startstopdir,o_iy] = pCounter(I_y_avg,foreground,0);


% peoplecountlegit = 0;
% 
% event = sum(sum(foreground,1));
% df = diff(event > 1);
% startIdx = find(df > 0) + 1; 
% stopIdx = find(df < 0);
% 
% e_len = length(startIdx);
% for i = 1:e_len
%     dir = mean(v_y_avg_all(startIdx(i):stopIdx(i)));
%     if dir > 0
%         peoplecountlegit = peoplecountlegit -1;
%     elseif dir < 0
%         peoplecountlegit = peoplecountlegit +1;
%     end
% end


% % optical flow using all points
% [v_y, v_y_avg, v_y_avg_all] = opticalflow(v);

% plot actual data
subplot(2, 1, 1);
himg = imshow(v(:,:,1),[20, 30]);
cd = get(himg,'CData');

% plot optical flow
subplot(2, 1, 2);
x = 1:n;
y = zeros(1,n);
v_y_avg_h = plot(x,'YDataSource','y');
hold on;
plot(1:n,ones(1,n)*1.75);
plot(1:n,ones(1,n)*-1.75);
% axis([0 n+50 -20 20]);
set(gca,'XMinorTick','on')
xlabel('Time Index');
ylabel('Vertical Velocity');

% refresh
for i = 1:n
    subplot(2, 1, 1);
    set(himg,'CData',v(:,:,i));
    y(i) = v_y_avg_all(i);
    refreshdata(v_y_avg_h);
    drawnow;
    pause(0.2);
end

