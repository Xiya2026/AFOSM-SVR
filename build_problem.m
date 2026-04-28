function prob = build_problem(cfg)
% build_problem: Core helper for AFOSM-SVR Example workflow.
prob = struct();
prob.Nx = 6;
prob.CaseName = "RotatingDisk_Example2_BurstMargin";
prob.BetaRef = NaN;
prob.PfRefPaper = 1.04e-3;

% Random variables:
% X1 = alpha_m (Weibull)
% X2 = S_u (Gaussian, unit: ksi)
% X3 = omega (Gaussian, in krpm)
% X4 = rho (Uniform)
% X5 = R_o (Gaussian)
% X6 = R_i (Gaussian)
prob.Dist = {"wbl", "norm", "norm", "unif", "norm", "norm"};

g_const = 385.82; % in/s^2
rho_lo = 0.28 / g_const;
rho_hi = 0.30 / g_const;
omega_mu = get_cfg_or(cfg, "omega_mean_krpm", 21);
omega_sd = get_cfg_or(cfg, "omega_std_krpm", 1);

% MATLAB Weibull uses (scale, shape). To match the paper's mean/std of alpha_m,
% the pair is set as [0.958, 25.508].
prob.Para = { ...
    [0.958, 25.508], ...
    [220, 5], ...
    [omega_mu, omega_sd], ...
    [rho_lo, rho_hi], ...
    [24, 0.5], ...
    [8, 0.3]};

if exist("ParaStat", "file") == 2
    prob = ParaStat(prob, "PtoS");
end

prob.Fung = @(x) rotating_disk_lsf(x);
end


