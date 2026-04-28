function prob = build_wing_problem(cfg)
% build_wing_problem: Core helper for AFOSM-SVR Example workflow.
prob = struct();
prob.Nx = 7;
prob.Dist = repmat({"norm"}, 1, prob.Nx);
mu_cfg = reshape(cfg.rv_mu, 1, []);
sd_cfg = reshape(cfg.rv_sd, 1, []);
prob.mu = mu_cfg;
prob.sd = sd_cfg;
prob.CaseName = "PaperExample4_FEM_Wing";
prob.Fung = @(x) wing_limit_state_batch(x, cfg);
if isfield(cfg, "require_uqlab_afosm") && ~isempty(cfg.require_uqlab_afosm)
    prob.RequireUQLabAFOSM = logical(cfg.require_uqlab_afosm);
else
    prob.RequireUQLabAFOSM = true;
end
if isfield(cfg, "uqlab_root_path") && ~isempty(cfg.uqlab_root_path)
    prob.UQLabRootPath = string(cfg.uqlab_root_path);
else
    prob.UQLabRootPath = "";
end
if isfield(cfg, "uqlab_afosm_algorithm") && ~isempty(cfg.uqlab_afosm_algorithm)
    prob.UQLabAFOSMAlgorithm = string(cfg.uqlab_afosm_algorithm);
else
    prob.UQLabAFOSMAlgorithm = "iHLRF";
end
if isfield(cfg, "uqlab_debug_paths") && ~isempty(cfg.uqlab_debug_paths)
    prob.UQLabDebugPaths = logical(cfg.uqlab_debug_paths);
else
    prob.UQLabDebugPaths = false;
end
if isfield(cfg, "uqlab_qpsolver") && ~isempty(cfg.uqlab_qpsolver)
    prob.UQLabQPSolver = string(cfg.uqlab_qpsolver);
else
    prob.UQLabQPSolver = "auto";
end
prob = ParaStat(prob, "StoP");
if ~isfield(prob, "mu") || isempty(prob.mu)
    prob.mu = mu_cfg;
end
if ~isfield(prob, "sd") || isempty(prob.sd)
    prob.sd = sd_cfg;
end
if ~isfield(prob, "Para") || isempty(prob.Para)
    prob.Para = cell(1, prob.Nx);
    for i = 1:prob.Nx
        prob.Para{i} = [mu_cfg(i), sd_cfg(i)];
    end
end
end


