function out = afosm_classic_uqlab(prob, cfg)
% afosm_classic_uqlab: Core helper for AFOSM-SVR Example workflow.
n_eval_counter = 0;
myRel = [];
try
    if exist("uqlab", "file") ~= 2
        error("UQLab is not available.");
    end
    ensure_uqlab_svr_ready(cfg);

    nx = prob.Nx;
    if ~(isfield(prob, "Dist") && isfield(prob, "Para"))
        error("Prob.Dist / Prob.Para are required by UQLab backend.");
    end
    if numel(prob.Dist) < nx || numel(prob.Para) < nx
        error("Prob.Dist / Prob.Para length mismatch with Prob.Nx.");
    end

    InputOpts = struct();
    InputOpts.Marginals = repmat(struct(), 1, nx);
    for i = 1:nx
        InputOpts.Marginals(i).Name = sprintf("X%d", i);
        InputOpts.Marginals(i).Type = map_distname_to_uqlab(prob.Dist{i});
        InputOpts.Marginals(i).Parameters = normalize_uqlab_dist_params(prob, i);
    end
    myInput = uq_call_with_reinitialize(@() uq_createInput(InputOpts), cfg);

    ModelOpts = struct();
    ModelOpts.mHandle = @(X) eval_model_counted(X);
    ModelOpts.isVectorized = true;
    myModel = uq_call_with_reinitialize(@() uq_createModel(ModelOpts), cfg);

    RelOpts = struct();
    RelOpts.Type = 'Reliability';
    RelOpts.Method = char(string(get_cfg_or(cfg, "uqlab_afosm_method", "FORM")));
    RelOpts.FORM.Algorithm = char(string(get_cfg_or(cfg, "uqlab_afosm_algorithm", "iHLRF")));
    RelOpts.FORM.MaxIterations = max(10, round(get_cfg_or(cfg, "max_iter_afosm", cfg.max_iter)));
    RelOpts.FORM.StopU = get_cfg_or(cfg, "conv_tol_afosm", cfg.conv_tol);
    RelOpts.FORM.StopG = get_cfg_or(cfg, "root_accept_tol", 1e-6);
    RelOpts.Model = myModel;
    RelOpts.Input = myInput;
    myRel = uq_call_with_reinitialize(@() uq_createAnalysis(RelOpts), cfg);

    [beta_uq, pf_uq, u_star, n_eval] = extract_uqlab_form_basic(myRel, nx);

    if isempty(u_star) || any(~isfinite(u_star))
        error("UQLab FORM returned empty/invalid design point.");
    end
    if ~isfinite(beta_uq)
        beta_uq = norm(u_star);
    end
    if ~isfinite(pf_uq) && isfinite(beta_uq)
        pf_uq = normcdf(-abs(beta_uq));
    end
    if n_eval_counter > 0
        n_eval = n_eval_counter;
    elseif ~isfinite(n_eval)
        n_eval = n_eval_counter;
    end

    out = struct();
    out.u_final = reshape(u_star, 1, []);
    out.beta = abs(beta_uq);
    out.pf = pf_uq;
    out.n_true_calls = n_eval;
    out.n_true_calls_search = n_eval;
    out.beta_hist = abs(beta_uq);
    out.u_hist = reshape(u_star, 1, []);
    out.afosm_backend = "uqlab";
    out.afosm_error = "";
catch ME
    if get_cfg_or(cfg, "require_uqlab_afosm", false)
        error("UQLab AFOSM is required (require_uqlab_afosm=true), but failed: %s", ME.message);
    end
    warning("UQLab AFOSM failed: %s. Falling back to internal AFOSM.", ME.message);
    cfg_fb = cfg;
    cfg_fb.afosm_backend = "classic";
    out = afosm_classic(prob, cfg_fb);
    out.afosm_backend = "internal_di_fallback";
    out.afosm_error = string(ME.message);
    if exist("myRel", "var") == 1 && isstruct(myRel) && isfield(myRel, "Results")
        try
            rf = strjoin(string(fieldnames(myRel.Results)), ",");
            out.afosm_error = out.afosm_error + " | Results fields=[" + rf + "]";
        catch
        end
    end
end

    function g = eval_model_counted(X)
        g = eval_g_x(prob, X);
        n_eval_counter = n_eval_counter + size(X, 1);
    end
end


