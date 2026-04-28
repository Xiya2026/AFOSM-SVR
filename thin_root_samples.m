function [u_keep, g_keep] = thin_root_samples(u_samples, g_samples, max_keep)
% thin_root_samples: Helper function in the AFOSM-SVR modular workflow.
if nargin < 3 || isempty(max_keep) || size(u_samples, 1) <= max_keep
    u_keep = u_samples;
    g_keep = g_samples;
    return;
end

n = size(u_samples, 1);
idx = unique(round(linspace(1, n, max_keep)));
u_keep = u_samples(idx, :);
g_keep = g_samples(idx, :);
end



