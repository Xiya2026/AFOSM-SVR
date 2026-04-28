function run_t = empty_run_template(nx)
run_t = struct();
run_t.method = '';
run_t.pf_beta = NaN;
run_t.cov_beta = NaN;
run_t.pf_is = NaN;
run_t.cov_is = NaN;
run_t.beta = NaN;
run_t.u_final = nan(1, nx);
run_t.x_final = nan(1, nx);
run_t.ncall_search = NaN;
run_t.ncall_is = NaN;
run_t.time_sec = NaN;
run_t.call_breakdown = struct("core", NaN, "refine", NaN, "hl", NaN);
end


