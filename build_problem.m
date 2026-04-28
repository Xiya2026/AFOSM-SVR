function prob = build_problem(case_id)
% build_problem: Helper function in the AFOSM-SVR modular workflow.
if exist("Problem", "file") == 2
    prob = Problem(case_id);
    return;
end

prob = struct();
switch case_id
    case 21
        prob.Nx = 2;
        prob.Dist = {"norm", "norm"};
        prob.mu = [0, 0];
        prob.sd = [1, 1];
        prob.Fung = @(x) 0.5 * (x(:, 1) - 2).^2 - 1.5 * (x(:, 2) - 5).^3 - 3;
        prob.CaseName = "NE21_high_nonlinearity";
        prob.BetaRef = NaN;
    case 22
        prob.Nx = 2;
        prob.Dist = {"norm", "norm"};
        prob.mu = [0, 0];
        prob.sd = [1, 1];
        prob.Fung = @(x) 25 - 2 * (x(:, 1) - x(:, 2)).^2 - 2 * (x(:, 1).^2 - x(:, 2).^2);
        prob.CaseName = "NE22_low_nonlinearity";
        prob.BetaRef = 1.705;
    case 23
        prob.Nx = 2;
        prob.Dist = {"norm", "norm"};
        prob.mu = [0, 0];
        prob.sd = [1, 1];
        prob.Fung = @(x) -(4/25) * (x(:, 1) - 1).^2 - x(:, 2) + 4;
        prob.CaseName = "NE23_quadratic_limit_state";
        prob.BetaRef = NaN;
    otherwise
        error("Unsupported case_id=%d. Use 21, 22 or 23.", case_id);
end

if exist("ParaStat", "file") == 2
    prob = ParaStat(prob, "StoP");
else
    prob.Para = { [prob.mu(1), prob.sd(1)], [prob.mu(2), prob.sd(2)] };
end
end



