function print_quality_notes(summary, cfg)
if ~cfg.run_is_eval
    return;
end
cov_alert = 0.20;
if isfinite(summary.svm.cov_mean) && summary.svm.cov_mean > cov_alert
    fprintf("Note: AFOSM(DI)-SVR IS CoV is %.3f (>%.2f); increase n_is_eval for stabler Pf estimates.\n", ...
        summary.svm.cov_mean, cov_alert);
end
if cfg.run_ga && isfinite(summary.ga.cov_mean) && summary.ga.cov_mean > cov_alert
    fprintf("Note: GA IS CoV is %.3f (>%.2f); increase n_is_eval for stabler Pf estimates.\n", ...
        summary.ga.cov_mean, cov_alert);
end
end


