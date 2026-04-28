function print_svr_backend_summary(backend_summary)
% print_svr_backend_summary: Helper function in the AFOSM-SVR modular workflow.
if isempty(backend_summary)
    return;
end
fprintf("\n------ SVR backend comparison ------\n");
primary_backend = upper(backend_summary(1).backend);
for ib = 1:numel(backend_summary)
    bi = backend_summary(ib);
    st = bi.stats;
    fprintf("[%s] Pf_IS(mean) = %.6e, CoV_IS(mean) = %.4f, beta(mean) = %.4f, rel.err(mean) = %.3f%%, Ncall(mean) = %.1f\n", ...
        upper(bi.backend), st.pf_mean, st.cov_mean, st.beta_mean, st.rel_err_mean, st.n_calls_mean);
    if ib > 1
        fprintf("      Delta vs %s: rel.err %+0.3f%%, Ncall %+0.1f\n", ...
            primary_backend, bi.delta_rel_err_vs_primary, bi.delta_calls_vs_primary);
    end
end
fprintf("------------------------------------\n\n");
end



