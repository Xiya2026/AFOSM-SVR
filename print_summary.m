function print_summary(summary, primary_backend, labels)
if nargin < 2 || isempty(primary_backend)
    primary_backend = "matlab";
end
if nargin < 3 || isempty(labels)
    labels = method_labels();
end
fprintf("\n========== Summary over runs ==========\n");
fprintf("Reference: Pf = %.6e, beta = %.4f\n\n", summary.reference_pf, summary.reference_beta);
if isfield(summary, "afosm_backend") && strlength(string(summary.afosm_backend)) > 0
    fprintf("AFOSM backend used: %s\n\n", char(upper(string(summary.afosm_backend))));
end
if isfield(summary, "afosm_error") && strlength(string(summary.afosm_error)) > 0
    fprintf("AFOSM fallback reason: %s\n\n", char(string(summary.afosm_error)));
end

fprintf("%s[%s]: u*_mean = %s\n", labels.afosm_beta_equation, char(upper(string(primary_backend))), format_u_row(summary.svm.u_mean));
fprintf("           Pf_IS(mean) = %.6e, CoV_IS(mean) = %.4f\n", ...
    summary.svm.pf_mean, summary.svm.cov_mean);
fprintf("           beta(mean) = %.4f, rel.err(mean) = %.3f%%, Ncall(mean) = %.1f\n\n", ...
    summary.svm.beta_mean, summary.svm.rel_err_mean, summary.svm.n_calls_mean);

fprintf("%s: u*_mean = %s\n", labels.afosm_direct_iteration, format_u_row(summary.afosm.u_mean));
fprintf("           Pf_IS(mean) = %.6e, CoV_IS(mean) = %.4f\n", ...
    summary.afosm.pf_mean, summary.afosm.cov_mean);
fprintf("           beta(mean) = %.4f, rel.err(mean) = %.3f%%, Ncall(mean) = %.1f\n\n", ...
    summary.afosm.beta_mean, summary.afosm.rel_err_mean, summary.afosm.n_calls_mean);

fprintf("GA       : u*_mean = %s\n", format_u_row(summary.ga.u_mean));
fprintf("           Pf_IS(mean) = %.6e, CoV_IS(mean) = %.4f\n", ...
    summary.ga.pf_mean, summary.ga.cov_mean);
fprintf("           beta(mean) = %.4f, rel.err(mean) = %.3f%%, Ncall(mean) = %.1f\n", ...
    summary.ga.beta_mean, summary.ga.rel_err_mean, summary.ga.n_calls_mean);
fprintf("Ncall counts true LSF calls in design-point search only (IS/MCS excluded).\n");
fprintf("=======================================\n\n");
end


