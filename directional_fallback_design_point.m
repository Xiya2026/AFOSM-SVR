function [u_best, n_true_calls] = directional_fallback_design_point(prob, cfg)
nx = prob.Nx;
n_true_calls = 0;
if nx ~= 2
    dirs = randn(500, nx);
    dirs = dirs ./ vecnorm(dirs, 2, 2);
else
    theta = linspace(0, 2 * pi, 720).';
    dirs = [cos(theta), sin(theta)];
end

best_beta = Inf;
best_u = zeros(1, nx);

for i = 1:size(dirs, 1)
    dir_i = dirs(i, :);
    g_fun = @(b) eval_g_counted(prob, b * dir_i);
    bgrid = linspace(0, cfg.beta_search_max, cfg.beta_search_n);
    gvals = arrayfun(g_fun, bgrid);
    idx = find(gvals(1:end - 1) .* gvals(2:end) <= 0, 1, "first");
    if isempty(idx)
        continue;
    end
    b1 = bgrid(idx);
    b2 = bgrid(idx + 1);
    try
        b_root = fzero(g_fun, [b1, b2]);
    catch
        [~, imin] = min(abs(gvals));
        b_root = bgrid(imin);
    end
    if b_root > 0 && b_root < best_beta
        best_beta = b_root;
        best_u = b_root * dir_i;
    end
end

u_best = best_u;

    function g = eval_g_counted(prob_i, u_i)
        g = eval_g_u(prob_i, u_i);
        n_true_calls = n_true_calls + size(u_i, 1);
    end
end


