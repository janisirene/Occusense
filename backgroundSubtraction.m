% implementation of Foreground-Adaptive Background subtraction based on
% McHugh, Konrad, Saligrama, Jodoin (2009)
% author: Janis Intoy
% updated: April 8, 2017

%% parameters
N = 15; % use N recents frames to estimate background PDF
sigma = 0.5; % std of Gaussian kernel for eq (1, 3) - guestimated
etaOrder = 1; % order of spatial neighborhood - 1 or 2 for now
nIterations = 3; % number of iterations of likelihood ratio testing - 2 or 3
gamma = 1; % small -> strong influence of MRF

% plotting parameters
doPlot = true; % flag to plot results or not
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
for ti = N+1:nFrames
    currentFrame = v(:, :, ti);
    
    % probability of background at each pixel
    sIdx = max(1, ti-N);
    previousFrames = v(:, :, sIdx:ti-1);
    previousFrames(~backgroundMask) = nan; % only include background pixels
    if ~isempty(previousFrames)
        Pb = nanmean(...
            normpdf(...
            bsxfun(@minus, currentFrame, previousFrames),...
            0, sigma),...
            3);
    end
    
    % initial detection mask
    e = (Pb < theta); % e = 1 -> foreground
    
%     if doPlot
%         [r, c] = find(e);
%         figure(50); clf; hold on;
%         imshow(v(:, :, ti), colorLims);
%         plot(c, r, 'r.', 'markersize', 20);
%         title(sprintf('frame = %i, iteration = %i', ti, 0));
%         keyboard;
%     end
    
    % probability of foreground at each pixel
    for ii = 1:nIterations
        Pf = nan(size(Pb));
        deltaQ = nan(size(Pb)); % array to store (Qf-Qb) as in eq (8)
        for nn = 1:(h*w)
            thisEta = nn + eta;
            thisEta(thisEta < 1 | thisEta > h*w) = [];
            
            isForeground = e(thisEta);
            
            if ~any(isForeground)
                % presumably no foreground object, so uniform PDF
                Pf(nn) = 1 / length(thisEta);
                deltaQ(nn) = -length(thisEta); % all background neighbors
            else
                thisEta = thisEta(isForeground);
                Pf(nn) = 1 / length(thisEta) *...
                    sum(normpdf(...
                        currentFrame(nn) - currentFrame(thisEta),...
                        0, sigma));
                deltaQ(nn) = length(thisEta) - sum(~isForeground);
            end
        end
        
        % update the detection mask - adaptive threshold
        e = (Pb ./ Pf < theta .* exp(deltaQ / gamma));
%         if doPlot && any(e(:))
%             [r, c] = find(e);
%             figure(50); clf; hold on;
%             imshow(v(:, :, ti), colorLims);
%             plot(c, r, 'r.', 'markersize', 20);
%             title(sprintf('frame = %i, iteration = %i', ti, ii));
%             keyboard;
%         end
    end
    
    % update mask
    backgroundMask(:, :, 1:end-1) = backgroundMask(:, :, 2:end);
    backgroundMask(:, :, end) = ~e;
    
    fullMask(:, :, ti) = e;
end

%% plotting
if doPlot
    
    doWrite = false;
    if doWrite
        [~, flname, ~] = fileparts(fname);
        saveName = sprintf('%s_N%i_sigma%i_eta%i_theta%i_nIt%i_gamma%i.avi',...
            flname,...
            N, sigma, etaOrder, round(100*theta), nIterations, round(100*gamma));
        vw = VideoWriter(saveName);
    end
    
    figure(100); clf;
    set(gcf, 'Color', 'w');
    subplot(2, 1, 2); hold on;
    himg = imshow(v(:, :, 1), colorLims);
    hDots = plot(-1, -1, 'r.', 'markersize', 20);
    
    subplot(2, 1, 1); hold on;
    hAx = plotyy(1:nFrames, squeeze(max(max(v, [], 1), [], 2)),...
        1:nFrames, squeeze(sum(sum(fullMask, 1), 2)));
    
    hvert = plot([0, 0], ylim, 'r-', 'linewidth', 2);
    title('max temperature in frame');
    ylabel(hAx(1), 'Max Frame temp');
    ylabel(hAx(2), '# detected foreground pixels');
    xlabel('time index');
    set(hAx, 'XLim', [1, nFrames]);
    
    if doWrite, open(vw); end
    for ti = 1:nFrames
        [r, c] = find(fullMask(:, :, ti));
        set(himg, 'CData', v(:, :, ti));
        set(hDots, 'XData', c, 'YData', r);
        set(hvert, 'XData', [ti, ti]);
        if doWrite, writeVideo(vw, getframe());end
        pause(.3);
    end
    if doWrite, close(vw); end
end