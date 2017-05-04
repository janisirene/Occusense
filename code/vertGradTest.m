mIy = mean(I_y_avg);


% s = sign(mIy);
% d = diff(s);
% 
% zc = find(d ~= 0);
% 
% figure(); 
% plot(mIy);
% vertLineThrough(zc);

start = startstopdir(:,1);
stop = startstopdir(:,2);

thrs = mean(abs(mIy(start(1):stop(1))));

for i = 1:length(mIy)
    if abs(mIy(i)) > thrs
        mIy(i) = -mIy(i)
end

for i = 2:length(mIy)-1
    if sign(mIy(i)) ~=  sign(mIy(i-1)) && sign(mIy(i)) ~=  sign(mIy(i+1))
        
        mIy(i) = - mIy(i);
    end
end

zc = nan(size(mIy));
for i = 1:length(mIy)-1
    if sign(mIy(i)) ~= sign(mIy(i+1)) && (mIy(i) ~= 0) && (mIy(i+1) ~= 0) 
        zc(i) = mIy(i+1) - mIy(i+1);
    end
end

figure(); 
plot(mIy);
vertLineThrough(find(~isnan(zc)));
