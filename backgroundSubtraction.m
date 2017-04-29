function fullMask = backgroundSubtraction(v, params)
% fullMask = backgroundSubtraction(v, params)
% implementation of Foreground-Adaptive Background subtraction based on
% McHugh, Konrad, Saligrama, Jodoin (2009)
% assumes that first several samples of videos are background
%
% inputs:
%   v - 3d array [4x16xtime] of temperatures
%   params - structure of parameters, see below
% output:
%   fullMask - logical array, same size as v, true when foreground, false
%       when background
%
% author: Janis Intoy
% updated: April 8, 2017

%% parameters
if ~exist('params', 'var')
    N = 20; % use N recents frames to estimate background PDF
    sigma = 0.5; % std of Gaussian kernel for eq (1, 3) - guestimated
    etaOrder = 1; % order of spatial neighborhood - 1 or 2 for now
    nIterations = 3; % number of iterations of likelihood ratio testing - 2 or 3
    gamma = 1; % small -> strong influence of MRF
    
    % plotting parameters
    doPlot = true; % flag to plot results or not   
else
    N = params.nBackgroundFrames;
    sigma = params.sigma;
    etaOrder = params.neighborhoodOrder;
    nIterations = params.nIterations;
    gamma = params.gamma;
    doPlot = params.doPlot;
end
colorLims = [20, 30];

%% derived parameters
theta = normpdf(3*sigma, 0, sigma); % threshold back vs foreground
[h, w, nFrames] = size(v);

switch etaOrder % (relative indices)
    case 1 % first order neighborhood
        eta = [-1 1 -h h];
    case 2 % second order neighborhood
        eta = [-1 1 -h h -h-1 -h+1 h-1 h+1];
end

%% iterate through frames and compute probabilities
backgroundMask = true(h, w, N); % assume everything is background to start
fullMask = false(size(v)); % for testing, not realistic to keep for real-time
prevBack = v(:, :, 1:N);
for ti = N+1:nFrames
    currentFrame = v(:, :, ti);
    
    % probability of background at each pixel - eq(1)
    sIdx = max(1, ti-N);
    Pb = nanmean(...
        normpdf(...
        bsxfun(@minus, currentFrame, prevBack),...
        0, sigma),...
        3);
    
    % initial detection mask - simplified likelihood ratio test
    % (equation in bottom of page 391, left column)
    e = (Pb < theta); % e = 1 -> foreground
    
    %{
    if doPlot
        [r, c] = find(e);
        figure(50); clf; hold on;
        imshow(v(:, :, ti), colorLims);
        plot(c, r, 'r.', 'markersize', 20);
        title(sprintf('frame = %i, iteration = %i', ti, 0));
        keyboard;
    end
    %}
    
    for ii = 1:nIterations
        Pf = nan(size(Pb)); % probability of foreground at each pixel
        deltaQ = nan(size(Pb)); % array to store (Qf-Qb) as in eq(8)
        for nn = 1:(h*w)
            % we want theforeground-only neighborhood  
            % (definition just before 3)
            thisEta = nn + eta;
            thisEta(thisEta < 1 | thisEta > h*w) = [];
            isForeground = e(thisEta);
            
            if ~any(isForeground)
                % presumably no foreground object, so uniform PDF
                Pf(nn) = 1/length(thisEta); % ??? Is this right?
                deltaQ(nn) = -length(thisEta); % all background neighbors
            else
                % this is the foreground only neighborhood
                thisEta = thisEta(isForeground);
                
                % probability of the foreground at this pixel eq(3)
                Pf(nn) = 1 / length(thisEta) *...
                    sum(normpdf(...
                    currentFrame(nn) - currentFrame(thisEta),...
                    0, sigma));
                deltaQ(nn) = length(thisEta) - sum(~isForeground);
            end
        end
        
        % update the detection mask - adaptive threshold
        % Do I do this every step or just once at the end???????
        e = (Pb ./ Pf < theta .* exp(deltaQ / gamma));
        % e = (Pb ./ Pf < theta);
        %{
        if doPlot && any(e(:))
            [r, c] = find(e);
            figure(50); clf; hold on;
            imshow(v(:, :, ti), colorLims);
            plot(c, r, 'r.', 'markersize', 20);
            title(sprintf('frame = %i, iteration = %i', ti, ii));
            keyboard;
        end
        %}
    end
    % now use the adaptive threshold
    e = (Pb ./ Pf < theta .* exp(deltaQ / gamma));
    
    % update previous backgrounds, only bumping when a pixel was background
    % anyways
    for nn = 1:size(prevBack)
        if ~e(nn) % if background, bump a far time
            [r, c] = ind2sub(size(prevBack), nn);
            prevBack(r, c, 1:end-1) = prevBack(r, c, 2:end);
            prevBack(r, c, end) = currentFrame(r, c);
        end
    end
    
    fullMask(:, :, ti) = e;
end

%% plotting
if doPlot
    doWrite = false;
    if doWrite
        flname = 'exampleVideo';
        saveName = sprintf('%s_N%i_sigma%i_eta%i_theta%i_nIt%i_gamma%i.avi',...
            flname,...
            N, sigma, etaOrder, round(100*theta), nIterations, round(100*gamma));
        vw = VideoWriter(saveName);
    end
    
    figure(100); clf;
    set(gcf, 'Color', 'w');
    subplot(2, 1, 1); hold on;
    himg = imshow(v(:, :, 1), colorLims);
    hDots = plot(-1, -1, 'r.', 'markersize', 20);
    
    subplot(2, 1, 2); hold on;
    hAx = plotyy(1:nFrames, squeeze(mean(mean(v, 1), 2)),...
        1:nFrames, squeeze(sum(sum(fullMask, 1), 2)));
    
    hvert = plot([0, 0], ylim, 'r-', 'linewidth', 2);
    title('max temperature in frame');
    ylabel(hAx(1), 'Mean Frame temp');
    ylabel(hAx(2), '# detected foreground pixels');
    xlabel('time index');
    set(hAx, 'XLim', [1, nFrames]);
    
    if doWrite, open(vw); end
    for ti = 1:nFrames
        [r, c] = find(fullMask(:, :, ti));
        set(himg, 'CData', v(:, :, ti));
        set(hDots, 'XData', c, 'YData', r);
        set(hvert, 'XData', [ti, ti]);
        if doWrite, writeVideo(vw, getframe(100));end
        pause(.1);
    end
    if doWrite, close(vw); end
end
end