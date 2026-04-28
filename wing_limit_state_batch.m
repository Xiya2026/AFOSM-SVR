function g = wing_limit_state_batch(x, cfg)
% wing_limit_state_batch: Core helper for AFOSM-SVR Example workflow.
if isvector(x)
    x = reshape(x, 1, []);
end
if size(x, 2) ~= 7
    error("Wing input must have 7 columns: [h1 h2 h3 h4 d1%% d2%% Fbar_kN].");
end
sigma_vm = evaluate_wing_stress_batch(x, cfg);
g = cfg.allowable_stress_mpa - sigma_vm;
end


