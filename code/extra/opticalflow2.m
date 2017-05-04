function [I_y, I_y_avg, I_t, v_y, v_y_avg_all] = opticalflow2(v)
% Calculates the direction of the opitcal flow using
% v_y = -I_t/I_y, I_t = dI/dt, and I_y = dI/dy


    % preallocation
    [l,m,n] = size(v);
    I_y = nan(l-1,m,n);
    I_y_avg = nan(l-1,n);
    I_t = nan(l-1,m,n);
    v_y = nan(l-1,m,n);
    
    for k = 1:n
        
        for i = 4:-1:2
            I_y(i-1,:,k) = v(i,:,k) - v(i-1,:,k);
        end
       
        if k > 1
            I_t(:,:,k) = I_y(:,:,k) - I_y(:,:,k-1); 
        end
        
        for i = 1:l-1
            for j = 1:m
                if I_t(i,j,k) == 0 || I_y(i,j,k) == 0

                else
                    v_y(i,j,k) = -I_t(i,j,k)./I_y(i,j,k);
                end
            end
        end
        
    end
    
    v_y_avg_all = nanmean(nanmean(v_y,2));

end