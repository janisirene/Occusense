% implementation of Foreground-Adaptive Background subtraction based on
% McHugh, Konrad, Saligrama, Jodoin (2009)
% author: Janis Intoy
% updated: April 8, 2017

%% parameters
N = 10; % use N recents frames to estimate background PDF
sigma = 1; % std of Gaussian kernel for eq (1, 3)
etaOrder = 1; % order of spatial neighborhood - 1 or 2 for now

doPlot = true; % flag to plot results or not

%% derived parameters
[h, w, nFrames] = size(v);

switch etaOrder % (relative indices)
    case 1 % first order neighborhood
        eta = [-1 1 -h h];
    case 2 % second order neighborhood
        eta = [-1 1 -h h -h-1 -h+1 h-1 h+1];
end

%% iterate through frames and compute probabilities
mnLikelihoodRatio = nan(nFrames, 1);
for ti = N+1:nFrames
    currentFrame = v(:, :, ti);
    % probability of background at each pixel
    Pb = 1/N * sum(...
        normpdf(...
            bsxfun(@minus, currentFrame, v(:, :, ti-N:ti-1)),...
            0, sigma),...
        3);
    
    % probability of foreground at each pixel
    Pf = nan(size(Pb));
    for ii = 1:(h*w)
        thisEta = ii + eta;
        thisEta(thisEta < 1 | thisEta > h*w) = [];
        Pf(ii) = 1 / length(thisEta) *...
            sum(normpdf(...
                    currentFrame(ii) - currentFrame(thisEta),...
                    0, sigma));
    end
    
    mnLikelihoodRatio(ti) = mean(Pb(:) ./ Pf(:)); 
end

if doPlot
    figure(1); clf;
    subplot(2, 1, 1);
    plot(1:nFrames, squeeze(max(max(v, [], 1), [], 2)));
    xlim([1, nFrames]);
    
    subplot(2, 1, 2);
    plot(1:nFrames, mnLikelihoodRatio);
    xlim([1, nFrames]);
end