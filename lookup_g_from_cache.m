function [hit, g_val] = lookup_g_from_cache(u_query, u_cache, g_cache, tol)
% lookup_g_from_cache: Helper function in the AFOSM-SVR modular workflow.
hit = false;
g_val = NaN;
if nargin < 4 || isempty(tol)
    tol = 1e-8;
end
if isempty(u_cache) || isempty(g_cache)
    return;
end
if isvector(u_cache)
    u_cache = reshape(u_cache, 1, []);
end
if size(u_cache, 2) ~= numel(u_query)
    return;
end
d = vecnorm(u_cache - reshape(u_query, 1, []), 2, 2);
[dmin, idx] = min(d);
if ~isempty(dmin) && isfinite(dmin) && dmin <= tol
    hit = true;
    g_val = g_cache(idx, 1);
end
end



