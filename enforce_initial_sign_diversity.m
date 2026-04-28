function [u_out, g_out, n_calls] = enforce_initial_sign_diversity(prob, u_in, g_in)
u_out = u_in;
g_out = g_in;
n_calls = 0;

has_fail = any(g_out < 0);
has_safe = any(g_out > 0);
if has_fail && has_safe
    return;
end

% Generic deterministic candidates in U-space (works across examples).
nx = size(u_in, 2);
if nx == 2
    dirs = [ ...
        1, 0;
       -1, 0;
        0, 1;
        0,-1;
        1, 1;
        1,-1;
       -1, 1;
       -1,-1];
    dirs = dirs ./ max(vecnorm(dirs, 2, 2), 1e-12);
    radii = [0.8, 1.5, 2.5, 3.5, 4.5];
    cand = zeros(numel(radii) * size(dirs, 1), 2);
    t = 1;
    for i = 1:numel(radii)
        for j = 1:size(dirs, 1)
            cand(t, :) = radii(i) * dirs(j, :);
            t = t + 1;
        end
    end
else
    dirs = randn(60, nx);
    dirs = dirs ./ max(vecnorm(dirs, 2, 2), 1e-12);
    radii = [1.0, 2.0, 3.0, 4.0];
    cand = [];
    for i = 1:numel(radii)
        cand = [cand; radii(i) * dirs]; %#ok<AGROW>
    end
end

for i = 1:size(cand, 1)
    if any(g_out < 0) && any(g_out > 0)
        break;
    end

    gg = eval_g_u(prob, cand(i, :));
    n_calls = n_calls + 1;

    if ~any(g_out < 0) && gg < 0
        [~, idx_rep] = max(g_out);
        u_out(idx_rep, :) = cand(i, :);
        g_out(idx_rep) = gg;
    elseif ~any(g_out > 0) && gg > 0
        [~, idx_rep] = min(g_out);
        u_out(idx_rep, :) = cand(i, :);
        g_out(idx_rep) = gg;
    end
end
end


