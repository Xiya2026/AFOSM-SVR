function stats = pack_stats(pf, beta, rel_err, n_calls, cov_pf, u_all)
% pack_stats: Helper function in the AFOSM-SVR modular workflow.
stats = struct();
stats.pf_mean = mean(pf);
stats.pf_std = std(pf);
stats.beta_mean = mean(beta);
stats.beta_std = std(beta);
stats.cov_mean = mean(cov_pf, "omitnan");
stats.cov_std = std(cov_pf, 0, "omitnan");
stats.rel_err_mean = mean(rel_err);
stats.rel_err_std = std(rel_err);
stats.n_calls_mean = mean(n_calls);
stats.n_calls_std = std(n_calls);
stats.u_mean = mean(u_all, 1);
stats.u_std = std(u_all, 0, 1);
end



