function sigma_vm = evaluate_wing_stress_batch(x, cfg)
% evaluate_wing_stress_batch: Core helper for AFOSM-SVR Example workflow.
stress_fun = str2func(cfg.stress_function);
sigma_vm = stress_fun(x, cfg);
sigma_vm = sigma_vm(:);
if numel(sigma_vm) ~= size(x, 1)
    error("Stress callback '%s' returned %d values for %d samples.", ...
        cfg.stress_function, numel(sigma_vm), size(x, 1));
end
if any(~isfinite(sigma_vm))
    error("Stress callback returned NaN/Inf values.");
end
end


