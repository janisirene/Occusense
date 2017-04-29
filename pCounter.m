function [pc,startstopdir] = pCounter(v,foreground, thr)

pc = 0;
%iy = mean(v,1);
iy = zeros(size(v, 2), 1);
for i = 1:length(iy)
    [m, mi] = max(abs(v(:, i)));
    iy(i) = sign(v(mi, i)) * m; 
end

event = sum(sum(foreground,1));
df = diff(event > thr);

startIdx = find(df > 0) + 1;
stopIdx = find(df < 0);
if startIdx(1) > stopIdx(1)
    startIdx = [1; startIdx];
end
if stopIdx(end) < startIdx(end)
    stopIdx = [stopIdx; length(event)];
end
kill = (startIdx == stopIdx);
startIdx(kill) = [];
stopIdx(kill) = [];

e_len = length(startIdx);
dirs = zeros(e_len,1);
for i = 1:e_len
    if iy(startIdx(i)) > iy(stopIdx(i))
        %     if mean(iy(startIdx(i):startIdx(i)+1)) > iy(stopIdx(i))
        pc = pc -1;
        dirs(i) = -1;
    elseif iy(startIdx(i)) < iy(stopIdx(i))
        pc = pc +1;
        dirs(i) = +1;
    end
end

startstopdir = [startIdx stopIdx dirs];
end

