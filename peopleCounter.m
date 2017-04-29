function [pc, dirs, event, ind] = peopleCounter(foreground, v_y_avg_all, thr)

pc = 0;
if ndims(foreground) == 3
event = sum(sum(foreground,1));
else
    event = foreground; 
end
df = diff(event > thr);
startIdx = find(df > 0) + 1; 
stopIdx = find(df < 0);

if isempty(startIdx) || startIdx(1) > stopIdx(1)
    startIdx = [1; startIdx];
end
if isempty(stopIdx) || stopIdx(end) < startIdx(end)
   stopIdx = [stopIdx; length(v_y_avg_all)]; 
end

e_len = length(startIdx);
dirs = nan(e_len, 1);
for i = 1:e_len
    if startIdx(i) == stopIdx(i)
        continue; 
    end
    dir = -mean(v_y_avg_all(startIdx(i):stopIdx(i)));
    if dir > 0
        pc = pc + 1;
    elseif dir < 0
        pc = pc - 1;
    end
    dirs(i) = dir;
end

bad = isnan(dirs);
dirs(bad) = [];
ind = [startIdx(~bad), stopIdx(~bad)];
end