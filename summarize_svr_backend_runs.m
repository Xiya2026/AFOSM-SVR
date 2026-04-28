function backend_summary = summarize_svr_backend_runs(svm_runs_by_backend, backend_names, pf_ref)
% summarize_svr_backend_runs: Helper function in the AFOSM-SVR modular workflow.
n_backend = numel(backend_names);
backend_summary = repmat(struct( ...
    "backend", "", ...
    "stats", struct(), ...
    "delta_rel_err_vs_primary", NaN, ...
    "delta_calls_vs_primary", NaN), n_backend, 1);

for ib = 1:n_backend
    runs_i = svm_runs_by_backend{ib};
    n = num_runs(runs_i);
    pf = nan(n, 1);
    beta = nan(n, 1);
    rel_err = nan(n, 1);
    calls = nan(n, 1);
    cov_pf = nan(n, 1);
    u_all = nan(n, 2);
    for i = 1:n
        run_i = get_run(runs_i, i);
        pf(i) = get_pf_for_error(run_i);
        if isfield(run_i, "beta_final")
            beta(i) = run_i.beta_final;
        elseif isfield(run_i, "beta")
            beta(i) = run_i.beta;
        end
        if isfield(run_i, "n_true_calls")
            calls(i) = run_i.n_true_calls;
        end
        cov_pf(i) = get_cov_for_report(run_i);
        if isfield(run_i, "u_final")
            u_all(i, :) = first_two(run_i.u_final);
        end
        rel_err(i) = abs(pf(i) - pf_ref) / max(pf_ref, eps) * 100;
    end
    backend_summary(ib).backend = char(lower(string(backend_names{ib})));
    backend_summary(ib).stats = pack_stats(pf, beta, rel_err, calls, cov_pf, u_all);
end

if n_backend >= 2
    base_rel_err = backend_summary(1).stats.rel_err_mean;
    base_calls = backend_summary(1).stats.n_calls_mean;
    for ib = 2:n_backend
        backend_summary(ib).delta_rel_err_vs_primary = ...
            backend_summary(ib).stats.rel_err_mean - base_rel_err;
        backend_summary(ib).delta_calls_vs_primary = ...
            backend_summary(ib).stats.n_calls_mean - base_calls;
    end
end
end



