function [u_best, idx_global] = learning_point_select(S_u, S_g, selected_mask, lambda)
% learning_point_select: Helper function in the AFOSM-SVR modular workflow.
n = size(S_u, 1);
if nargin < 3 || isempty(selected_mask)
    selected_mask = false(n, 1);
end
if numel(selected_mask) < n
    selected_mask(end + 1:n) = false;
end

available = find(~selected_mask);
if isempty(available)
    available = 1:n;
end

g_mean = mean(abs(S_g)) + eps;
d_mean = mean(vecnorm(S_u, 2, 2)) + eps;
q = abs(S_g(available)) ./ g_mean + lambda * vecnorm(S_u(available, :), 2, 2) ./ d_mean;
[~, idx_local] = min(q(:));
idx_global = available(idx_local);
u_best = S_u(idx_global, :);
end



