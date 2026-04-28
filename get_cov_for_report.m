function cov_pf = get_cov_for_report(run_struct)
if isfield(run_struct, "cov_is") && isfinite(run_struct.cov_is)
    cov_pf = run_struct.cov_is;
else
    cov_pf = NaN;
end
end


