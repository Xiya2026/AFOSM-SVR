function check_dependencies(cfg)
required = {"ParaStat", "normcdf", "norminv", "icdf", "Main_MCS"};
if ~cfg.run_mcs_only
    required = [required, {"Main_AFOSM_SVM", "lhsdesign", "uqlab", ...
        "uq_createModel", "uq_evalModel", "uq_createInput", "uq_createAnalysis"}];
    if cfg.run_classic_afosm
        required = [required, {char(cfg.afosm_function), "uq_createInput", "uq_createAnalysis"}];
    end
end
for i = 1:numel(required)
    req_i = char(string(required{i}));
    if exist(req_i, "file") ~= 2
        error("Required function '%s' not found.", req_i);
    end
end
if exist(cfg.stress_function, "file") ~= 2
    error("Stress callback '%s' not found.", cfg.stress_function);
end
end


