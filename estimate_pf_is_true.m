function [pf_est, cov_est] = estimate_pf_is_true(prob, u_design, n_samples, seed)
if nargin >= 4 && ~isempty(seed)
    rng(seed, "twister");
end

if isempty(u_design) || any(~isfinite(u_design))
    pf_est = NaN;
    cov_est = NaN;
    return;
end

u_design = reshape(u_design, 1, []);
n = max(1000, round(n_samples));
v = randn(n, prob.Nx) + u_design;
g = eval_g_u(prob, v);

expo = -v * u_design.' + 0.5 * sum(u_design.^2);
expo = min(max(expo, -700), 700);
w = exp(expo);
z = double(g < 0) .* w;

pf_est = mean(z);
if ~isfinite(pf_est) || pf_est <= 0
    cov_est = Inf;
else
    var_z = var(z, 1);
    cov_est = sqrt(max(var_z, 0) / n) / pf_est;
end
end


