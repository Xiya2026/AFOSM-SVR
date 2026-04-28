function e = relative_error_pct(pf_est, pf_ref)
if ~isfinite(pf_est) || ~isfinite(pf_ref) || pf_ref <= 0
    e = NaN;
else
    e = abs(pf_est - pf_ref) / pf_ref * 100;
end
end


