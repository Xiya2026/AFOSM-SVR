function [S_u, S_g, added_u_iter, added_g_iter, n_added] = append_points_with_tracking( ...
    S_u, S_g, u_add, g_add, cfg, added_u_iter, added_g_iter)

if isempty(u_add)
    n_added = 0;
    return;
end

if isvector(u_add)
    u_add = reshape(u_add, 1, []);
end
if isscalar(g_add)
    g_add = repmat(g_add, size(u_add, 1), 1);
end

new_u = zeros(0, size(S_u, 2));
new_g = zeros(0, 1);

for i = 1:size(u_add, 1)
    uu = u_add(i, :);
    gg = g_add(i, 1);
    if any(~isfinite(uu)) || ~isfinite(gg)
        continue;
    end

    if isempty(S_u)
        min_dist = Inf;
    else
        min_dist = min(vecnorm(S_u - uu, 2, 2));
    end
    if ~isempty(new_u)
        min_dist = min(min_dist, min(vecnorm(new_u - uu, 2, 2)));
    end

    if min_dist <= cfg.duplicate_tol
        continue;
    end

    new_u = [new_u; uu]; %#ok<AGROW>
    new_g = [new_g; gg]; %#ok<AGROW>
end

if isempty(new_u)
    n_added = 0;
    return;
end

S_u = [S_u; new_u];
S_g = [S_g; new_g];
added_u_iter = [added_u_iter; new_u];
added_g_iter = [added_g_iter; new_g];
n_added = size(new_u, 1);
end


