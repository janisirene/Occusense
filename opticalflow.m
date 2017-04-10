function [v_y, v_y_avg, v_y_avg_all] = opticalflow(v)
% Calculates the direction of the opitcal flow using
% v_y = -I_t/I_y, I_t = dI/dt, and I_y = dI/dy


    % preallocation
    [l,m,n] = size(v);
    v_y = zeros(l-1,m,n);
    v_y_avg = zeros(m,n);
    v_y_avg_all = zeros(1,n);

    for k = 2:n
        I_t = v(:,:,k) - v(:,:,k-1);
        I_t_bounded = I_t(2:4,:);
        I_y = zeros(3,16);
        for i = 4:-1:2
            I_y(i-1,:) = v(i,:,k) - v(i-1,:,k);
        end
        
        for i = 1:l-1
            for j = 1:m
                if I_t_bounded(i,j) == 0 || I_y(i,j) == 0
    
                else
                    v_y(i,j,k) = I_t_bounded(i,j)./I_y(i,j);
                end
            end
        end
        v_y_avg(:,k) = mean(v_y(:,:,k));
        v_y_avg_all(k) = mean(v_y_avg(:,k));

    end



end

