function [u_refined, beta_refined, n_true_calls] = refine_design_on_true_lsf(prob, u_in, cfg)
n_true_calls = 0;
u_refined = reshape(u_in, 1, []);
beta_in = norm(u_refined);
beta_refined = beta_in;

if ~all(isfinite(u_refined)) || beta_in < 1e-12
    return;
end
alpha = u_refined / beta_in;
[beta_root, n_beta_calls, ok_ref] = solve_beta_on_direction(prob, alpha, max(beta_in, cfg.beta_min), cfg);
n_true_calls = n_true_calls + n_beta_calls;
if ok_ref && isfinite(beta_root) && beta_root > 0
    beta_refined = beta_root;
    u_refined = beta_root * alpha;
else
    beta_refined = beta_in;
end
end


