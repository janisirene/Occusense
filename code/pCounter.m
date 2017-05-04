function [pc,startstopdir,iy] = pCounter(v,foreground, thr)

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
    mAbsIy = mean(abs(iy(startIdx(i):stopIdx(i))));
    
    % smooth signal-ish
    for k = startIdx(i)+1:stopIdx(i)
        if sign(iy(k-1)) ~= sign(iy(k)) && abs(iy(k))<0.5*mAbsIy
            iy(k) = - iy(k);
        end
    end
    
    if mEvent <= thr2
        continue;
    end
    if startIdx(i) == stopIdx(i)
        
        iyend = 0; 
        if iy(startIdx(i)) > iyend
            pc = pc -1;
            dirs(i) = -1;
        elseif iy(startIdx(i)) < iyend
            pc = pc +1;
            dirs(i) = +1;
        end
        
    else    
        for k = startIdx(i)+1:stopIdx(i)
            if sign(iy(k-1)) > sign(iy(k)) 
                pc = pc -1;
                dirs(i) = dirs(i)-1;
            elseif sign(iy(k-1)) < sign(iy(k)) 
                pc = pc +1;
                dirs(i) = dirs(i)+1;
            end
        end
    end
    

    
%     if iy(startIdx(i)) > iyend
%         pc = pc -1;
%         dirs(i) = -1;
%     elseif iy(startIdx(i)) < iyend
%         pc = pc +1;
%         dirs(i) = +1;
%     end
end

startstopdir = [startIdx stopIdx dirs];
end

