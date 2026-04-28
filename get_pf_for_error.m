function pf = get_pf_for_error(run_struct)
if isfield(run_struct, "pf_is") && isfinite(run_struct.pf_is) && run_struct.pf_is >= 0
    pf = run_struct.pf_is;
elseif isfield(run_struct, "pf_beta") && isfinite(run_struct.pf_beta)
    pf = run_struct.pf_beta;
elseif isfield(run_struct, "pf") && isfinite(run_struct.pf)
    pf = run_struct.pf;
elseif isfield(run_struct, "beta") && isfinite(run_struct.beta)
    pf = normcdf(-abs(run_struct.beta));
elseif isfield(run_struct, "beta_final") && isfinite(run_struct.beta_final)
    pf = normcdf(-abs(run_struct.beta_final));
else
    pf = NaN;
end
end


