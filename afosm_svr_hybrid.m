function out = afosm_svr_hybrid(prob, cfg, pf_ref, seed_tag, svr_backend)
% Hybrid AFOSM-SVR loop:
% 1) choose a candidate design point from current samples
% 2) solve SVR-based FORM update
% 3) append true model calls near the root line and candidate point
% 4) retrain the surrogate and check convergence
nx = prob.Nx;
n_true_calls = 0;
max_iter_svm = get_cfg_or(cfg, "max_iter_svm", cfg.max_iter);
conv_tol_svm = get_cfg_or(cfg, "conv_tol_svm", cfg.conv_tol);
if nargin < 4 || isempty(seed_tag)
    seed_tag = 1;
end
if nargin < 5 || isempty(svr_backend)
    svr_backend = get_cfg_or(cfg, "svr_backend_primary", "uqlab");
end
svr_backend = char(lower(string(svr_backend)));

% Initial DOE in standard normal space.
u0 = make_initial_u_samples(cfg, nx);
g0 = eval_g_u(prob, u0);
n_true_calls = n_true_calls + size(u0, 1);
n_calls_init = size(u0, 1);
n_calls_root = 0;
n_calls_cand = 0;
n_calls_add = 0;

S_u = u0;
S_g = g0;
model = fit_svr_model(S_u, S_g, cfg, svr_backend);

selected_mask = false(size(S_u, 1), 1);
u_prev = zeros(1, nx);
beta_prev = Inf;
stop_reason = "max_iter";
stop_iter = NaN;
stop_err_beta = NaN;
stop_err_u = NaN;
last_err_beta = NaN;
last_err_u = NaN;

trace = struct("rel_err", [], "sample_count", []);
stages = cell(0, 1);
stages{1, 1} = struct( ...
    "iter", 0, ...
    "svr_backend", svr_backend, ...
    "model", model, ...
    "S_u", S_u, ...
    "added_u", zeros(0, nx), ...
    "root_u", zeros(0, nx), ...
    "cand_u", zeros(0, nx), ...
    "u_design", zeros(0, nx), ...
    "u_current", zeros(0, nx), ...
    "beta", NaN);
beta_hist = [];
u_hist = [];

for k = 1:max_iter_svm
    if numel(selected_mask) < size(S_u, 1)
        selected_mask(end + 1:size(S_u, 1)) = false;
    end

    % Step A: choose one informative point from the existing sample pool.
    [u_current, idx_global] = learning_point_select(S_u, S_g, selected_mask, cfg.lambda);
    selected_mask(idx_global) = true;

    % Step B: solve FORM/iHLRF on the current SVR model.
    [u_form, beta_form, ok_form, msg_form] = solve_svr_form_ihlrf(prob, cfg, model, u_current);
    if ~ok_form
        error("AFOSM(DI)-SVR inner FORM/iHLRF failed (UQLab required): %s", char(string(msg_form)));
    end
    u_new = reshape(u_form, 1, []);
    if any(~isfinite(u_new))
        u_new = u_current;
    end
    if norm(u_new) < cfg.beta_min
        dir0 = u_current / max(norm(u_current), 1e-12);
        if norm(dir0) < 1e-12
            dir0 = [zeros(1, nx - 1), 1];
        end
        u_new = cfg.beta_min * dir0;
    end
    beta_sol = max(abs(beta_form), cfg.beta_min);
    if ~isfinite(beta_sol)
        beta_sol = max(norm(u_new), cfg.beta_min);
    end
    alpha = u_new / max(norm(u_new), 1e-12);
    if norm(alpha) < 1e-12
        alpha = u_current / max(norm(u_current), 1e-12);
    end

    % Step C: sample along the estimated root line and query true model.
    [line_u_hat, line_g_hat] = collect_rootline_samples_svr( ...
        model, alpha, max(beta_sol, cfg.beta_min), cfg);
    [line_u, ~] = thin_root_samples( ...
        line_u_hat, line_g_hat, get_cfg_or(cfg, "max_root_samples_keep", 8));
    if ~isempty(line_u)
        line_g = eval_g_u(prob, line_u);
        n_line = size(line_u, 1);
        n_true_calls = n_true_calls + n_line;
        n_calls_root = n_calls_root + n_line;
    else
        line_g = zeros(0, 1);
    end
    g_new = eval_g_u(prob, u_new);
    n_true_calls = n_true_calls + 1;
    n_calls_cand = n_calls_cand + 1;
    g_hat_new_pre = predict_svr_model(model, u_new);

    root_u_iter = [];
    root_g_iter = [];
    cand_u_iter = [];
    cand_g_iter = [];
    added_u_iter = [];
    added_g_iter = [];
    n_before = size(S_u, 1);
    [S_u, S_g, root_u_iter, root_g_iter, n_add] = ...
        append_points_with_tracking(S_u, S_g, line_u, line_g, cfg, root_u_iter, root_g_iter);
    [S_u, S_g, cand_u_iter, cand_g_iter, n_add2] = ...
        append_points_with_tracking(S_u, S_g, u_new, g_new, cfg, cand_u_iter, cand_g_iter);
    added_u_iter = [root_u_iter; cand_u_iter];
    added_g_iter = [root_g_iter; cand_g_iter];

    n_added_iter = n_add + n_add2;
    if n_added_iter > 0
        model = fit_svr_model(S_u, S_g, cfg, svr_backend);
        trace_seed = cfg.master_seed + 700000 + seed_tag * 100 + k;
        [pf_iter, ~] = estimate_pf_is_true(prob, u_new, cfg.n_is_trace, trace_seed);
        rel_err_iter = abs(pf_iter - pf_ref) / max(pf_ref, eps) * 100;
        trace.rel_err(end + 1:end + n_added_iter, 1) = rel_err_iter;
        trace.sample_count(end + 1:end + n_added_iter, 1) = (n_before + 1:n_before + n_added_iter).';
    end

    % Optional refinement near nearest SVR limit-state point (Step 7).
    do_step7 = should_enable_step7(cfg, k, beta_sol, beta_prev, g_new, g_hat_new_pre, S_g);
    if cfg.enable_step7 && do_step7
        u_extra = svr_nearest_design_point(model, u_new, cfg);
        if ~isempty(u_extra)
            g_extra = eval_g_u(prob, u_extra);
            n_true_calls = n_true_calls + 1;
            n_calls_add = n_calls_add + 1;
            n_before = size(S_u, 1);
            [S_u, S_g, added_u_iter, added_g_iter, n_add3] = ...
                append_points_with_tracking(S_u, S_g, u_extra, g_extra, cfg, added_u_iter, added_g_iter);
            if n_add3 > 0
                model = fit_svr_model(S_u, S_g, cfg, svr_backend);
                trace_seed = cfg.master_seed + 750000 + seed_tag * 100 + k;
                [pf_iter, ~] = estimate_pf_is_true(prob, u_new, cfg.n_is_trace, trace_seed);
                rel_err_iter = abs(pf_iter - pf_ref) / max(pf_ref, eps) * 100;
                trace.rel_err(end + 1:end + n_add3, 1) = rel_err_iter;
                trace.sample_count(end + 1:end + n_add3, 1) = (n_before + 1:n_before + n_add3).';
            end
        end
    end

    beta_hist(k, 1) = abs(beta_sol); %#ok<AGROW>
    u_hist(k, :) = u_new; %#ok<AGROW>

    stages{end + 1, 1} = struct( ...
        "iter", k, ...
        "svr_backend", svr_backend, ...
        "model", model, ...
        "S_u", S_u, ...
        "added_u", added_u_iter, ...
        "root_u", root_u_iter, ...
        "cand_u", reshape(u_new, 1, []), ...
        "u_design", u_new, ...
        "u_current", u_current, ...
        "beta", abs(beta_sol));

    % Convergence check on reliability index and design-point movement.
    err_beta = abs(beta_hist(k) - beta_prev) / max(abs(beta_hist(k)), 1e-8);
    err_u = norm(u_new - u_prev, Inf);
    last_err_beta = err_beta;
    last_err_u = err_u;
    meet_beta = (k > 1) && (err_beta <= conv_tol_svm);
    meet_u = (k > 1) && (err_u <= conv_tol_svm);
    if meet_beta || meet_u
        if meet_beta && meet_u
            stop_reason = "beta+u";
        elseif meet_beta
            stop_reason = "beta";
        else
            stop_reason = "u";
        end
        stop_iter = k;
        stop_err_beta = err_beta;
        stop_err_u = err_u;
        break;
    end

    beta_prev = beta_hist(k);
    u_prev = u_new;
end

if ~isfinite(stop_iter)
    stop_iter = size(u_hist, 1);
    stop_reason = "max_iter";
    stop_err_beta = last_err_beta;
    stop_err_u = last_err_u;
end

if isempty(beta_hist)
    beta_final = norm(u_prev);
    u_final = u_prev;
else
    beta_final = beta_hist(end);
    u_final = u_hist(end, :);
end

pf_beta = normcdf(-abs(beta_final));
pf_proxy = normcdf(-abs(beta_final));

out = struct();
out.beta_final = abs(beta_final);
out.u_final = u_final;
out.x_final = u_to_x(prob, u_final); % physical design point via inverse transform
out.pf_beta = pf_beta;
out.pf_proxy = pf_proxy;
out.pf_est = pf_beta;
out.n_true_calls = n_true_calls;
out.n_true_calls_search = n_true_calls;
out.call_breakdown = struct("n_init", n_calls_init, "n_root", n_calls_root, ...
    "n_cand", n_calls_cand, "n_add", n_calls_add);
out.trace = trace;
out.stages = stages;
out.u_init = u0;
out.g_init = g0;
out.beta_hist = beta_hist;
out.u_hist = u_hist;
out.svr_backend = svr_backend;
out.stop_reason = char(stop_reason);
out.stop_iter = stop_iter;
out.stop_err_beta = stop_err_beta;
out.stop_err_u = stop_err_u;
out.stop_tol = conv_tol_svm;
end




