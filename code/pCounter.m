function [pc,startstopdir] = pCounter(v,foreground, thr)

pc = 0;
iy = mean(v,1);
% iy = zeros(size(v, 2), 1);
% for i = 1:length(iy)
%     [m, mi] = max(abs(v(:, i)));
%     iy(i) = sign(v(mi, i)) * m;
% end

if ndims(foreground) == 3
    event = sum(sum(foreground,1));
    thr2 = 3;
else
    event = foreground;
    thr2 = thr + 1;
end
df = diff(event > thr);

startIdx = find(df > 0) + 1;
stopIdx = find(df < 0);

if isempty(startIdx)
    pc = 0;
    startstopdir = [];
    return;
end

if startIdx(1) > stopIdx(1)
    startIdx = [1; startIdx];
end
if stopIdx(end) < startIdx(end)
    stopIdx = [stopIdx; length(event)];
end
% kill = (startIdx == stopIdx);
% startIdx(kill) = [];
% stopIdx(kill) = [];

e_len = length(startIdx);
dirs = zeros(e_len,1);
for i = 1:e_len
    mEvent = mean(event(startIdx(i):stopIdx(i)));
    if mEvent <= thr2
        continue;
    end
    if startIdx(i) == stopIdx(i)
        iyend = 0;
    else    
        iyend = iy(stopIdx(i));
    end
    if iy(startIdx(i)) > iyend
        %     if mean(iy(startIdx(i):startIdx(i)+1)) > iy(stopIdx(i))
        pc = pc -1;
        dirs(i) = -1;
    elseif iy(startIdx(i)) < iyend
        pc = pc +1;
        dirs(i) = +1;
    end
end

startstopdir = [startIdx stopIdx dirs];
end

