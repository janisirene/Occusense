function [pc,startstopdir] = pCounter(v,foreground)

    pc = 0;
    iy = mean(v,1);

    event = sum(sum(foreground,1));
    df = diff(event > 1);
    startIdx = find(df > 0); 
    stopIdx = find(df < 0);

    e_len = length(startIdx);
    dirs = zeros(e_len,1);
    for i = 1:e_len
        if iy(startIdx(i)) > iy(stopIdx(i))
            pc = pc -1;
            dirs(i) = -1;
        elseif iy(startIdx(i)) < iy(stopIdx(i))
            pc = pc +1;
            dirs(i) = +1; 
        end
    end
    
    startstopdir = [startIdx stopIdx dirs];
end

