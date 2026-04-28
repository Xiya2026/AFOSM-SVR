function fprintf_compare_row(base_name, base_s, svm_s, pf_ref, cfg)
call_gain = percent_gain(base_s.calls_search_mean, svm_s.calls_search_mean);
time_gain = percent_gain(base_s.time_mean, svm_s.time_mean);
eq_time_gain = percent_gain(base_s.eq_search_time_mean, svm_s.eq_search_time_mean);

if isfinite(pf_ref)
    err_base = abs(base_s.pf_mean - pf_ref) / max(pf_ref, eps) * 100;
    err_svm = abs(svm_s.pf_mean - pf_ref) / max(pf_ref, eps) * 100;
    err_gain = percent_gain(err_base, err_svm);
    if cfg.report_equivalent_time
        fprintf("  vs %-6s: search calls %+7.2f%%, EqFEMTime %+7.2f%%, wall time %+7.2f%%, MCS error %+7.2f%%\n", ...
            base_name, call_gain, eq_time_gain, time_gain, err_gain);
    else
        fprintf("  vs %-6s: search calls %+7.2f%%, wall time %+7.2f%%, MCS error %+7.2f%%\n", ...
            base_name, call_gain, time_gain, err_gain);
    end
else
    if cfg.report_equivalent_time
        fprintf("  vs %-6s: search calls %+7.2f%%, EqFEMTime %+7.2f%%, wall time %+7.2f%%\n", ...
            base_name, call_gain, eq_time_gain, time_gain);
    else
        fprintf("  vs %-6s: search calls %+7.2f%%, wall time %+7.2f%%\n", ...
            base_name, call_gain, time_gain);
    end
end
end


