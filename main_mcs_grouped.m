function [Pf, CoV] = main_mcs_grouped(prob, n_total, group_size, cfg)
n_done = 0;
n_fail = 0;
n_groups = ceil(n_total / group_size);
t0 = tic;

for ig = 1:n_groups
    n_this = min(group_size, n_total - n_done);
    x = zeros(n_this, prob.Nx);
    for j = 1:prob.Nx
        x(:, j) = random(prob.Dist{j}, prob.Para{j}(1), prob.Para{j}(2), n_this, 1);
    end

    g = prob.Fung(x);
    n_fail = n_fail + sum(g < 0);
    n_done = n_done + n_this;

    if cfg.mcs_group_progress
        pf_now = n_fail / max(n_done, 1);
        if pf_now <= 0
            cov_now = Inf;
        else
            cov_now = sqrt((1 - pf_now) / (n_done * pf_now));
        end
        fprintf("  MCS group %d/%d: n=%d (acc=%d), Pf=%.6e, CoV=%.4f, elapsed=%.1fs\n", ...
            ig, n_groups, n_this, n_done, pf_now, cov_now, toc(t0));
    end
end

Pf = n_fail / n_done;
if Pf <= 0
    CoV = Inf;
else
    CoV = sqrt((1 - Pf) / (n_done * Pf));
end
end


