% gaussian blob test
v = nan(4, 16, 10);

direction = +1;

figure(1);
for t = 1:size(v, 3)
    g = exp(-(bsxfun(@plus, ((-1:2)' +direction* (t-5)).^2, ((1:16) - 8.5).^2)) / 5^2);
    v(:, :, t) = g;
    
    clf;
    imshow(g, [0, 1]);
    pause(.1);
end

%%
[I_y, I_y_avg, I_t, v_y, v_y_avg_all] = opticalflow(v);
disp(v_y_avg_all');

%%
[dy, ~, dt] = gradient(v);
of = dt ./ dy;

figure(101);
for i = 1:size(v, 3)
    clf;
    imshow(of(:, :, i), [-15 15]);
    pause(.1);
end