function model = fit_svr_model(S_u, S_g, cfg, svr_backend)
% fit_svr_model: Core helper for AFOSM-SVR Example workflow.
if nargin < 4 || isempty(svr_backend)
    svr_backend = get_cfg_or(cfg, "svr_backend_primary", "uqlab");
end
svr_backend = lower(string(svr_backend));

valid = isfinite(S_g) & all(isfinite(S_u), 2);
S_u = S_u(valid, :);
S_g = S_g(valid, :);

[S_u, idx] = unique(round(S_u, cfg.unique_round_digits), "rows", "stable");
S_g = S_g(idx, :);

if size(S_u, 1) < 3
    S_u = [S_u; zeros(3 - size(S_u, 1), size(S_u, 2))];
    S_g = [S_g; zeros(3 - size(S_g, 1), 1)];
end

y_train = S_g;

switch svr_backend
    case "uqlab"
        uq_state = ensure_uqlab_svr_ready(cfg);
        meta_opts = struct();
        meta_opts.Type = 'Metamodel';
        meta_opts.MetaType = 'SVR';
        meta_opts.ExpDesign.X = S_u;
        meta_opts.ExpDesign.Y = y_train;
        meta_opts.Loss = char(string(get_cfg_or(cfg, "uqlab_svr_loss", "l1-eps")));
        meta_opts.Kernel.Isotropic = get_cfg_or(cfg, "uqlab_svr_kernel_isotropic", 0);
        meta_opts.Optim.Method = char(string(get_cfg_or(cfg, "uqlab_svr_optim_method", "BFGS")));
        meta_opts.QPSolver = uq_state.qp_solver;
        meta_opts.Display = 'quiet';
        raw_model = uq_call_with_reinitialize(@() uq_createModel(meta_opts), cfg);
    case "matlab"
        try
            raw_model = fitrsvm(S_u, y_train, ...
                "KernelFunction", "rbf", ...
                "KernelScale", cfg.svm_kernel_scale, ...
                "BoxConstraint", cfg.svm_box, ...
                "Epsilon", cfg.svm_epsilon, ...
                "Standardize", true);
        catch
            raw_model = fitrsvm(S_u, y_train, ...
                "KernelFunction", "rbf", ...
                "KernelScale", 1.0, ...
                "BoxConstraint", max(1, cfg.svm_box / 5), ...
                "Epsilon", max(cfg.svm_epsilon, 1e-4), ...
                "Standardize", true);
        end
    otherwise
        error("Unsupported SVR backend: %s", svr_backend);
end

model = struct();
model.backend = char(svr_backend);
model.raw_model = raw_model;
end


