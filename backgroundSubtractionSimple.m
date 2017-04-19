function out = backgroundSubtractionSimple(v, params)

%% parameters
if ~exist('params', 'var')
    N = 15; % use N recents frames to estimate background PDF
    thr = 1; % std above which is foreground
    etaOrder = 1; % order of spatial neighborhood - 1 or 2 for now
    nIterations = 3; % number of iterations of likelihood ratio testing - 2 or 3
    gamma = 1; % small -> strong influence of MRF
    rho = .5; % weight of most recent frame
    
    % plotting parameters
    doPlot = true; % flag to plot results or not   
else
    N = params.nBackgroundFrames;
    thr = params.threshold;
    etaOrder = params.neighborhoodOrder;
    nIterations = params.nIterations;
    gamma = params.gamma;
    rho = params.rho;
    doPlot = params.doPlot;
end
colorLims = [20, 30];

%% initial conditions
[~, ~, nFrames] = size(v);
mu = mean(v(:, :, 1:N), 3);
vr = var(v(:, :, 1:N), [], 3);

switch etaOrder % (relative indices)
    case 1 % first order neighborhood
        eta = [0 1 0; 1 0 1; 0 1 0];
    case 2 % second order neighborhood
        eta = [1 1 1; 1 0 1; 1 1 1];
end
seta = sum(eta(:));

out = nan(size(v));

%% loop through frames
for ti = N+1:nFrames
    thisFrame = v(:, :, ti);
    
    mut = rho * thisFrame + (1 - rho ) * mu;
    vrt = rho  * (thisFrame-mut).^2 + (1-rho ) * vr;
    
    gs = (thisFrame - mut) ./ sqrt(vrt);
    e = gs > thr;
    
    for ii = 1:nIterations
        mut = e .* mu + (1 - e) .* (rho  * thisFrame + (1 - rho ) * mu);
        vrt = e .* vr + (1 - e) .* (rho * (thisFrame-mut).^2 + (1-rho ) * vr);
        gs = (thisFrame - mut) ./ sqrt(vrt);
        
        neighFore = imfilter(e, eta);
        deltaQ = 2 * neighFore - seta;
        
        adThr = thr * exp(-deltaQ / gamma);
        
        e = gs > adThr;
    end
    
    % update running gaussian pdf if pixel was background
    mu = e .* mu + (1 - e) .* (rho  * thisFrame + (1 - rho ) * mu);
    vr = e .* vr + (1 - e) .* (rho * (thisFrame-mut).^2 + (1-rho ) * vr);
    
    out(:, :, ti) = (thisFrame - mu) ./ sqrt(vr) - adThr;
end
end