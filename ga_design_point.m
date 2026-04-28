function out = ga_design_point(prob, cfg)
% ga_design_point: Core helper for AFOSM-SVR Example workflow.
nx = prob.Nx;
lb = -cfg.ga_bound * ones(1, nx);
ub = cfg.ga_bound * ones(1, nx);
n_true_calls = 0;

obj = @(u) sum(u.^2);
    function g = eval_g_with_count(u)
        g = eval_g_u(prob, u);
        n_true_calls = n_true_calls + size(u, 1);
    end
nonlcon = @(u) deal([], eval_g_with_count(u));

u_sol = [];
if exist("ga", "file") == 2
    try
        opts = optimoptions("ga", ...
            "PopulationSize", cfg.ga_population, ...
            "MaxGenerations", cfg.ga_generations, ...
            "Display", "off", ...
            "ConstraintTolerance", 1e-6, ...
            "MutationFcn", @mutationadaptfeasible);
        [u_ga, ~] = ga(obj, nx, [], [], [], [], lb, ub, nonlcon, opts);
        u_sol = u_ga;
    catch
        u_sol = [];
    end
end

if isempty(u_sol) && exist("fmincon", "file") == 2
    try
        opts = optimoptions("fmincon", "Display", "off", "Algorithm", "sqp");
        starts = max(5, round(cfg.ga_multistart));
        best_f = Inf;
        best_u = [];
        for i = 1:starts
            u0 = lb + rand(1, nx) .* (ub - lb);
            [u_i, f_i, flag] = fmincon(obj, u0, [], [], [], [], lb, ub, nonlcon, opts);
            if flag > 0 && f_i < best_f
                best_f = f_i;
                best_u = u_i;
            end
        end
        if ~isempty(best_u)
            u_sol = best_u;
        end
    catch
        u_sol = [];
    end
end

if isempty(u_sol)
    [u_sol, n_dir_calls] = directional_fallback_design_point(prob, cfg);
    n_true_calls = n_true_calls + n_dir_calls;
end

beta = norm(u_sol);
if beta < 1e-12
    alpha = [1, zeros(1, nx - 1)];
else
    alpha = u_sol / beta;
end
[beta_refined, n_beta_calls, ok_ref] = solve_beta_on_direction(prob, alpha, max(beta, 0.1), cfg);
n_true_calls = n_true_calls + n_beta_calls;
if ok_ref
    u_refined = beta_refined * alpha;
else
    u_refined = u_sol;
end

out = empty_run_template(nx);
out.u_final = u_refined;
out.x_final = u_to_x(prob, u_refined);
out.beta = norm(u_refined);
out.ncall_search = n_true_calls;
end


