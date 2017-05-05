function [v, events, peopleCount, isBackground] = simulateLongVideo(minFrames, pr, nEvents)
% v = simulateLongVideo(minFrames, pr)
% inputs:
%   minFrames - minimum length of the video  [default = 500];
%   pr - probability of motion event coming up next [default = .3]
% output:
%   v - [4 x 16 x nFrames]
%   events - [nMotions x 2] array with start index of event and number
%           of people in/out
%   peopleCount - total people count at end of video
if ~exist('minFrames', 'var')
    minFrames = 500; 
end
if ~exist('pr', 'var')
    pr = 0.3; 
end
if ~exist('nEvents', 'var')
    nEvents = inf; 
end
temp = load('labelleddata.mat'); % foregrounds, backgrounds, direction
foregrounds = temp.foregrounds;
backgrounds = temp.backgrounds;
direction = temp.direction;
clear temp;

nBackgrounds = length(backgrounds);
nForegrounds = length(direction);

bused = false(nBackgrounds, 1);
fused = false(nForegrounds, 1);

v = nan(4, 16, minFrames);
isBackground = false(minFrames, 1);

% start with a background
r = randi(nBackgrounds);
bused(r) = true;

bg = backgrounds{r};
l = size(bg, 3);
sIdx = 1;
v(:, :, sIdx:sIdx+l-1) = bg;
isBackground(sIdx:sIdx+l-1) = true;
sIdx = sIdx + l;



peopleCount = 0;
events = [];
while 1
    % for contiguity - keep means of attached frames similar
    prevFrame = v(:, :, sIdx-1);
    mPrev = mean(prevFrame(:));
    
    r = rand(1);
    if r < pr % motion
        idx = find(~fused);
        r2 = randi(length(idx));
        fidx = idx(r2);
        
        fused(fidx) = true;
        
        fg = foregrounds{fidx};
        
        d = rand(1);
        if d > .5
            fg = flipud(fg);
            peopleCount = peopleCount - direction(fidx);
            events = [events; sIdx, -direction(fidx)];
        else
            peopleCount = peopleCount + direction(fidx);
            events = [events; sIdx, direction(fidx)];
        end
        
        fg1 = fg(:, :, 1);
        fg = fg - mean(fg1(:)) + mPrev;
        l = size(fg, 3);
        v(:, :, sIdx:sIdx+l-1) = fg;
        
        isBackground(sIdx:sIdx+l-1) = false;
        sIdx = sIdx + l;
    else % more background
        idx = find(~bused);
        r2 = randi(length(idx));
        fidx = idx(r2);
        
        bused(fidx) = true;
        
        bg = backgrounds{fidx};
        bg1 = bg(:, :, 1);
        bg = bg - mean(bg1(:)) + mPrev;
        l = size(bg, 3);
        v(:, :, sIdx:sIdx+l-1) = bg;
        isBackground(sIdx:sIdx+l-1) = true;
        sIdx = sIdx + l;
    end
    if ~any(fused)
        fused = false(size(direction)); 
    end
    if ~any(bused)
        bused = false(size(backgrounds)); 
    end
    
    if sIdx > minFrames
        break; 
    end
    if size(events, 1) == nEvents
        v = v(:, :, 1:sIdx - 1);
        break;
    end
end

% mmv = squeeze(mean(mean(v, 1), 2));
% dmmv = diff(mmv);
% dmmv(~isBackground) = nan;
% sd = nanstd(dmmv);
% 
% bad = find(abs(dmmv) > 2.5 * sd) + 1;
% bad(bad == 1 | bad == length(mmv)) = [];
% for bi = 1:length(bad)
%     bidx = bad(bi);
%     mPrev = mean(mean(v(:, :, bidx-1), 1), 2);
%     mHere = mean(mean(v(:, :, bidx), 1), 2);
%     
%     v(:, :, bidx:end) = v(:, :, bidx:end) - mHere + mPrev + randn(1)*.01;
% end
end
