function [pf_i, cov_i] = choose_pf_cov_for_report(r, cfg)
if cfg.run_is_eval && isfinite(r.pf_is)
    pf_i = r.pf_is;
    cov_i = r.cov_is;
else
    pf_i = r.pf_beta;
    cov_i = r.cov_beta;
end
end


