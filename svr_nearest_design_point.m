function u_star = svr_nearest_design_point(model, u0, cfg)
u_star = [];
if exist("fmincon", "file") ~= 2
    return;
end

nx = numel(u0);
lb = -cfg.search_bound * ones(1, nx);
ub = cfg.search_bound * ones(1, nx);
obj = @(u) sum(u.^2);
nonlcon = @(u) deal([], predict_svr_model(model, reshape(u, 1, [])));
opts = optimoptions("fmincon", ...
    "Display", "off", ...
    "Algorithm", "sqp", ...
    "ConstraintTolerance", 1e-6, ...
    "OptimalityTolerance", 1e-6, ...
    "StepTolerance", 1e-8, ...
    "MaxFunctionEvaluations", 2000);

try
    [u_sol, ~, exitflag] = fmincon(obj, u0, [], [], [], [], lb, ub, nonlcon, opts);
    if exitflag > 0 && all(isfinite(u_sol))
        u_star = u_sol;
    end
catch
    u_star = [];
end
end


