function summary = summarize_method(runs, pf_ref, cfg)
% summarize_method: Core helper for AFOSM-SVR Example workflow.
summary = struct();
n = numel(runs);
beta = nan(n, 1);
pf_report = nan(n, 1);
cov_report = nan(n, 1);
calls_search = nan(n, 1);
calls_is = nan(n, 1);
time_sec = nan(n, 1);
eq_time_search = nan(n, 1);

for i = 1:n
    r = runs(i);
    beta(i) = r.beta;
    [pf_i, cov_i] = choose_pf_cov_for_report(r, cfg);
    pf_report(i) = pf_i;
    cov_report(i) = cov_i;
    calls_search(i) = r.ncall_search;
    calls_is(i) = r.ncall_is;
    time_sec(i) = r.time_sec;
    eq_time_search(i) = r.ncall_search * cfg.true_lsf_eval_cost_sec;
end

summary.n = n;
summary.beta_mean = mean(beta, "omitnan");
summary.beta_std = std(beta, 0, "omitnan");
summary.pf_mean = mean(pf_report, "omitnan");
summary.pf_std = std(pf_report, 0, "omitnan");
summary.cov_mean = mean(cov_report, "omitnan");
summary.cov_std = std(cov_report, 0, "omitnan");
summary.calls_search_mean = mean(calls_search, "omitnan");
summary.calls_search_std = std(calls_search, 0, "omitnan");
summary.calls_is_mean = mean(calls_is, "omitnan");
summary.calls_is_std = std(calls_is, 0, "omitnan");
summary.time_mean = mean(time_sec, "omitnan");
summary.time_std = std(time_sec, 0, "omitnan");
summary.eq_search_time_mean = mean(eq_time_search, "omitnan");
summary.eq_search_time_std = std(eq_time_search, 0, "omitnan");

if isfinite(pf_ref)
    rel_err = abs(pf_report - pf_ref) / max(pf_ref, eps) * 100;
    summary.rel_err_mean = mean(rel_err, "omitnan");
    summary.rel_err_std = std(rel_err, 0, "omitnan");
else
    summary.rel_err_mean = NaN;
    summary.rel_err_std = NaN;
end
end


