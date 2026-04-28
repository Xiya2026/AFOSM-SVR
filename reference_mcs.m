function [pf, cov_pf] = reference_mcs(prob, n_samples, seed, chunk_size)
% reference_mcs: Helper function in the AFOSM-SVR modular workflow.
if nargin < 4 || isempty(chunk_size)
    chunk_size = 2e5;
end

rng(seed, "twister");
n_fail = 0;
n_done = 0;

while n_done < n_samples
    n_now = min(chunk_size, n_samples - n_done);
    u = randn(n_now, prob.Nx);
    g = eval_g_u(prob, u);
    n_fail = n_fail + sum(g < 0);
    n_done = n_done + n_now;
end

pf = n_fail / n_samples;
if pf <= 0
    cov_pf = Inf;
else
    cov_pf = sqrt((1 - pf) / (n_samples * pf));
end
end



