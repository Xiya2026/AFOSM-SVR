function summary = summarize_results(svm_runs, afosm_runs, ga_runs, pf_ref, beta_ref)
n = num_runs(svm_runs);
nx = numel(get_run(svm_runs, 1).u_final);
svm_pf = zeros(n, 1);
svm_beta = zeros(n, 1);
svm_err = zeros(n, 1);
svm_calls = zeros(n, 1);
svm_cov = zeros(n, 1);
svm_u = nan(n, nx);

af_pf = zeros(n, 1);
af_beta = zeros(n, 1);
af_err = zeros(n, 1);
af_calls = zeros(n, 1);
af_cov = zeros(n, 1);
af_u = nan(n, nx);

ga_pf = zeros(n, 1);
ga_beta = zeros(n, 1);
ga_err = zeros(n, 1);
ga_cov = zeros(n, 1);
ga_u = nan(n, nx);
ga_calls = zeros(n, 1);

for i = 1:n
    svm_i = get_run(svm_runs, i);
    af_i = get_run(afosm_runs, i);
    ga_i = get_run(ga_runs, i);

    svm_pf(i) = get_pf_for_error(svm_i);
    svm_beta(i) = svm_i.beta_final;
    svm_calls(i) = svm_i.n_true_calls;
    svm_cov(i) = get_cov_for_report(svm_i);
    svm_u(i, :) = row_u_fixed_dim(svm_i.u_final, nx);
    svm_err(i) = abs(svm_pf(i) - pf_ref) / max(pf_ref, eps) * 100;

    af_pf(i) = get_pf_for_error(af_i);
    af_beta(i) = af_i.beta;
    af_calls(i) = af_i.n_true_calls;
    af_cov(i) = get_cov_for_report(af_i);
    af_u(i, :) = row_u_fixed_dim(af_i.u_final, nx);
    af_err(i) = abs(af_pf(i) - pf_ref) / max(pf_ref, eps) * 100;

    ga_pf(i) = get_pf_for_error(ga_i);
    ga_beta(i) = ga_i.beta;
    ga_cov(i) = get_cov_for_report(ga_i);
    ga_u(i, :) = row_u_fixed_dim(ga_i.u_final, nx);
    if isfield(ga_i, "n_true_calls") && isfinite(ga_i.n_true_calls)
        ga_calls(i) = ga_i.n_true_calls;
    else
        ga_calls(i) = 0;
    end
    ga_err(i) = abs(ga_pf(i) - pf_ref) / max(pf_ref, eps) * 100;
end

summary = struct();
summary.reference_pf = pf_ref;
summary.reference_beta = beta_ref;
summary.Nx = nx;

summary.svm = pack_stats(svm_pf, svm_beta, svm_err, svm_calls, svm_cov, svm_u);
summary.afosm = pack_stats(af_pf, af_beta, af_err, af_calls, af_cov, af_u);
summary.ga = pack_stats(ga_pf, ga_beta, ga_err, ga_calls, ga_cov, ga_u);

summary.afosm_backend = "";
summary.afosm_error = "";
for i = 1:n
    af_i = get_run(afosm_runs, i);
    if isfield(af_i, "afosm_backend") && strlength(string(af_i.afosm_backend)) > 0
        summary.afosm_backend = string(af_i.afosm_backend);
        break;
    end
end
for i = 1:n
    af_i = get_run(afosm_runs, i);
    if isfield(af_i, "afosm_error") && strlength(string(af_i.afosm_error)) > 0
        summary.afosm_error = string(af_i.afosm_error);
        break;
    end
end
end


