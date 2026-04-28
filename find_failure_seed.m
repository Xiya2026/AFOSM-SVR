function [u_fail, ok, n_eval] = find_failure_seed(prob, cfg)
% find_failure_seed: Helper function in the AFOSM-SVR modular workflow.
nx = prob.Nx;
n_eval = 0;
ok = false;
u_fail = zeros(1, nx);

if nx == 2
    theta = linspace(0, 2 * pi, 120).';
    dirs = [cos(theta), sin(theta)];
else
    dirs = randn(400, nx);
    dirs = dirs ./ max(vecnorm(dirs, 2, 2), 1e-12);
end

bgrid = linspace(0, cfg.beta_search_expand_max, 80);
best_beta = Inf;
best_u = [];

for i = 1:size(dirs, 1)
    a = dirs(i, :);
    gvals = zeros(size(bgrid));
    for j = 1:numel(bgrid)
        gvals(j) = eval_g_u(prob, bgrid(j) * a);
    end
    n_eval = n_eval + numel(bgrid);
    idx = find(gvals(1:end - 1) .* gvals(2:end) <= 0, 1, "first");
    if isempty(idx)
        continue;
    end
    b1 = bgrid(idx);
    b2 = bgrid(idx + 1);
    gfun = @(b) eval_g_u(prob, b * a);
    try
        b_root = fzero(gfun, [b1, b2]);
        n_eval = n_eval + 8;
    catch
        [~, imin] = min(abs(gvals));
        b_root = bgrid(imin);
    end
    if (b_root > 0) && (b_root < best_beta)
        best_beta = b_root;
        best_u = b_root * a;
    end
end

if ~isempty(best_u)
    ok = true;
    u_fail = best_u;
end
end



