for i = 1:length(backgrounds)
    disp(i);
   f = backgrounds{i};
   mf = squeeze(mean(mean(f, 1), 2));
   v = std(f(:));
   
   newframe = randn(4, 16) * v;
   newframe = newframe - mean(newframe(:));
   if mf(1) < mf(end)
       newframe = newframe + mf(1);
       
       f2 = cat(3, f, newframe);
   else
       newframe = newframe + mf(end);
       f2 = cat(3, newframe, f);
   end
   
   figure(1); clf;
   mmv = squeeze(mean(mean(f2, 1), 2));
   plot(mf, 'bo'); hold on; plot(mmv, 'rx-');
    keyboard;
   backgrounds{i} = f2;
end
save('labelleddata.mat', '-append', 'backgrounds');

%% manually edit backgrounds
for i = 1:length(backgrounds)
    v = backgrounds{i};
    if i == 1
        v = v(:, :, 8:47);
    elseif i == 5
        v = v(:, :, 8:end);
    elseif i == 8
        v = v(:, :, 8:end);
    elseif i == 13
        v = v(:, :, 8:end);
    elseif i == 17
        v = v(:, :, 5:end);
        elseif i == 21
        v = v(:, :, 4:end);
    end
    backgrounds{i} = v;
end
save('labelleddata.mat', '-append', 'backgrounds');