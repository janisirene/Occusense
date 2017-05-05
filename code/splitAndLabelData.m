% dumb classifier for labelled data so that we can break videos into
% background and foreground to simulate longer videos

ptToData = 'OccusenseData';

conditions = {'OUT', 'IN', 'In&Out',...
    fullfile('TWO', 'IN&OUT'), fullfile('TWO', 'OUT')};
thresholds = {[26, 24.5], [26, 24], [24, 23.5], [24, 23], [24, 23]};

%% list of all files
backgrounds = {};
cb = 0;

foregrounds = {};
direction = [];
cf = 0;

cnt = 0;
for ci = 1:length(conditions)
    hiThr = thresholds{ci}(1);
    loThr = thresholds{ci}(2);
    
    dr = dir(fullfile(ptToData, conditions{ci}, '*.txt'));
    
    for dri = 1:length(dr)
        cnt = cnt + 1;
        v = readOccusenseVideo(fullfile(ptToData, conditions{ci}, dr(dri).name));
        
        mx = squeeze(max(max(v, [], 1), [], 2));
        
        isMotion = mx > hiThr;
        
        md = 0; % not above hiThr;
        for jj = 1:length(mx) % forward histeresis
            if mx(jj) > hiThr
                md = 1; % on mode
            elseif md == 1 && mx(jj) > loThr
                isMotion(jj) = true;
            else
                md = 0; 
            end
        end
        
        md = 0; % not above hiThr;
        for jj = length(mx):-1:1 % backwards histeresis
            if mx(jj) > hiThr
                md = 1; % on mode
            elseif md == 1 && mx(jj) > loThr
                isMotion(jj) = true;
            else
                md = 0; 
            end
        end
        
        % start and end indices of motions
        df = diff(isMotion);
        startIndices = find(df > 0) + 1;
        endIndices = find(df < 0);
        
        if startIndices(1) > endIndices(1)
            startIndices = [1; startIndices]; 
        end
        if startIndices(end) > endIndices(end)
            endIndices = [endIndices; length(isMotion)]; 
        end
        startIndices = max(1, startIndices - 1);
        endIndices = min(endIndices + 1, length(mx));
        assert(length(startIndices) == length(endIndices));
        
        % guess which direction each motion is (1 for in, -1 for out)
        peopleIncr = zeros(size(startIndices));
        for jj = 1:length(peopleIncr)
            last1 = mean(mean(v(1, :, endIndices(jj)-1:endIndices(jj))));
            last4 = mean(mean(v(4, :, endIndices(jj)-1:endIndices(jj))));
            if last1 > last4
                peopleIncr(jj) = -1;  % out
            elseif last1 < last4
                peopleIncr(jj) = 1; % in
            end
        end
        
        % manual corrections
        switch dr(dri).name
            case 'mo4.txt'
                peopleIncr(1) = -1;
            case 'mo6.txt'
                peopleIncr(2) = 1;
            case 'person1.txt'
                peopleIncr(1) = -1;
            case {'person2.txt', 'person3.txt', 'person4.txt', 'person5.txt',...
                    'person7.txt', 'person8.txt'}
                peopleIncr = [-1; 1];
            case {'person6.txt'}
                peopleIncr = [-1; 1; -1; 1];
            case {'two_io.txt', 'two_io3.txt', 'two_io5.txt'}
                peopleIncr = [-2; 2];
            case 'two_io2.txt'
                peopleIncr = [-1; -1; 2];
            case {'two_io4.txt'}
                peopleIncr = [-2; 2; 0];
            case {'two_out.txt', 'two_out3.txt', 'two_out4.txt'}
                peopleIncr = [-1; -1];
            case 'two_out2.txt'
                peopleIncr = -2;
        end
        
        for jj = 1:length(startIndices)
            if startIndices(jj) == 1 || endIndices(jj) == length(mx)
                 continue; % not a complete exit/entry
            end
            cf = cf + 1;
            foregrounds{cf} = v(:, :, startIndices(jj):endIndices(jj));
            direction(cf) = peopleIncr(jj);
        end
        
        % start and end indices of backgrounds
        df = diff(~isMotion);
        startIndices = find(df > 0) + 1;
        endIndices = find(df < 0);
        
        if startIndices(1) > endIndices(1)
            startIndices = [1; startIndices]; 
        end
        if startIndices(end) > endIndices(end)
            endIndices = [endIndices; length(isMotion)]; 
        end
        startIndices = startIndices + 1;
        endIndices = endIndices - 1;
        assert(length(startIndices) == length(endIndices));
        
        for jj = 1:length(startIndices)
            if endIndices(jj) - startIndices(jj) > 1
                cb = cb + 1;
                backgrounds{cb} = v(:, :, startIndices(jj):endIndices(jj));
            end
        end
        
%         figure(200); clf; hold on;
%         plot(mx, 'k-', 'linewidth', 2);
%         lineThrough([loThr, hiThr], 'k', gca, ':');
%         plot(24+5 * isMotion, 'r-', 'linewidth', 2);
%         xlim([1, length(mx)]);
%         title(sprintf('%s %s', conditions{ci}, dr(dri).name));
%         xlabel(num2str(peopleIncr'));
%         keyboard;
    end
end

save('labelleddata.mat', 'backgrounds', 'foregrounds', 'direction');

%% sanity checks
for i = 1:length(backgrounds)
    if isempty(backgrounds{i})
        continue; 
    end
    figure(100); clf;
    plot(squeeze(max(max(backgrounds{i}, [], 1), [], 2)));
    ylim([20, 35]);
    keyboard;
end

%%
for i = 1:length(foregrounds)
    if isempty(backgrounds{i})
        continue; 
    end
    figure(100); clf;
    plot(squeeze(max(max(foregrounds{i}, [], 1), [], 2)));
    ylim([20, 35]);
    keyboard;
end