function cov_pf = get_cov_for_report(run_struct)
% get_cov_for_report: Helper function in the AFOSM-SVR modular workflow.
if isfield(run_struct, "cov_is") && isfinite(run_struct.cov_is)
    cov_pf = run_struct.cov_is;
else
    cov_pf = NaN;
end
end



