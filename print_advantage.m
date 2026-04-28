function print_advantage(summary, cfg, pf_ref_for_err)
if ~(cfg.run_classic_afosm || cfg.run_ga)
    return;
end

fprintf("Relative improvement vs AFOSM(DI)-SVR:\n");
if cfg.run_classic_afosm
    fprintf_compare_row('AFOSM(DI)', summary.afosm, summary.svm, pf_ref_for_err, cfg);
end
if cfg.run_ga
    fprintf_compare_row('GA', summary.ga, summary.svm, pf_ref_for_err, cfg);
end
end


