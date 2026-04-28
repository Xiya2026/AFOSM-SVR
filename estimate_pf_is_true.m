function [pf_est, cov_est] = estimate_pf_is_true(prob, u_design, n_samples, seed, cfg)
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

p0 = cfg.is_mixture_origin_prob;
nx = prob.Nx;
v = randn(n, nx);
pick_origin = rand(n, 1) < p0;
if any(~pick_origin)
    v(~pick_origin, :) = v(~pick_origin, :) + u_design;
end
g = eval_g_u(prob, v);

log_const = -0.5 * nx * log(2 * pi);
log_phi0 = log_const - 0.5 * sum(v.^2, 2);
dv1 = v - u_design;
log_phi1 = log_const - 0.5 * sum(dv1.^2, 2);

loga = log(max(p0, realmin)) + log_phi0;
logb = log(max(1 - p0, realmin)) + log_phi1;
logm = max(loga, logb);
logq = logm + log(exp(loga - logm) + exp(logb - logm));

logw = log_phi0 - logq;
logw = min(max(logw, cfg.is_log_floor), cfg.is_log_ceil);
w = exp(logw);
z = double(g < 0) .* w;

pf_est = mean(z);
if ~isfinite(pf_est) || pf_est <= 0
    cov_est = Inf;
else
    var_z = var(z, 1);
    cov_est = sqrt(max(var_z, 0) / n) / pf_est;
end
end


