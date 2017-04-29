function [I_y, I_y_avg, I_t, v_y, v_y_avg_all] = opticalflow(v)
% Calculates the direction of the opitcal flow using
% v_y = -I_t/I_y, I_t = dI/dt, and I_y = dI/dy


    % preallocation
    [l,m,n] = size(v);
    I_y = zeros(l-1,m,n);
    I_y_avg = zeros(l-1,n);
    I_t = zeros(l-1,n);
    v_y = zeros(l-1,n);
    
    for k = 1:n
        
%         I_t = v(:,:,k) - v(:,:,k-1);
%         I_t_bounded = I_t(2:4,:);
        for i = 4:-1:2
            I_y(i-1,:,k) = v(i,:,k) - v(i-1,:,k);
        end
        
        if (mean(mean(I_y(:,:,k))) ~= 0)
            summed = sum(I_y(:,:,k),2);
            for i = 1:l-1
                if (mean(I_y(i,:,k)) ~=0)
                    indices = find(I_y(i,:,k) ~= 0);
                    ind_leng = length(indices);
                    I_y_avg(i,k) = summed(i)/ind_leng;
                end
            end
            if k > 1
                I_t(:,k) = I_y_avg(:,k) - I_y_avg(:,k-1);
            end
            
            for i = 1:l-1
                for j = 1:n
                    if I_t(i,j) == 0 || I_y_avg(i,j) == 0

                    else
                        v_y(i,j) = -I_t(i,j)./I_y_avg(i,j);
                    end
                end
            end
            
        end

    end

    v_y(find(v_y == 0)) = nan;
    v_y_avg_all = nanmean(v_y,1);

end

