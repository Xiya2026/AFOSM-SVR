function out = afosm_classic_uqlab(prob, cfg)
% afosm_classic_uqlab: Helper function in the AFOSM-SVR modular workflow.
nx = prob.Nx;
if nx ~= 2
    warning("UQLab AFOSM backend is only enforced for 2D examples. Falling back to internal AFOSM.");
    cfg_fb = cfg;
    cfg_fb.afosm_backend = "classic";
    out = afosm_classic(prob, cfg_fb);
    out.afosm_backend = "internal_fallback";
    out.afosm_error = "UQLab AFOSM only enabled for 2D.";
    return;
end

try
    ensure_uqlab_svr_ready(cfg);
    n_eval_counter = 0;

    InputOpts = struct();
    for i = 1:nx
        para = get_dist_para(prob, i);
        dist_i = lower(prob.Dist{i});
        InputOpts.Marginals(i).Name = sprintf('X%d', i);
        switch dist_i
            case {"norm", "normal"}
                InputOpts.Marginals(i).Type = 'Gaussian';
                InputOpts.Marginals(i).Parameters = [para(1), para(2)];
            otherwise
                error("UQLab AFOSM backend currently supports only normal marginals in 2D examples.");
        end
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

    [beta_uq, pf_uq, u_star, x_star, n_eval] = extract_uqlab_form_results(myRel, prob);
    if ~isfinite(beta_uq) && ~isfinite(pf_uq) && isempty(u_star) && isempty(x_star)
        error("Unable to parse UQLab reliability results (beta/Pf/design point are all missing).");
    end
    if isempty(u_star) && ~isempty(x_star)
        u_star = x_to_u(prob, x_star);
    end
    if isempty(u_star) || any(~isfinite(u_star))
        error("UQLab returned no valid design point in U-space.");
    end
    if ~isfinite(beta_uq)
        beta_uq = norm(u_star);
    end
    if ~isfinite(pf_uq)
        pf_uq = normcdf(-abs(beta_uq));
    end
    if ~isfinite(n_eval)
        n_eval = 0;
    end
    if n_eval_counter > 0
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
    dbg = "";
    if exist("myRel", "var") == 1
        dbg = summarize_uqlab_analysis_object(myRel);
    end
    out.afosm_error = string(ME.message) + dbg;
end

    function g = eval_model_counted(X)
        g = eval_g_x(prob, X);
        n_eval_counter = n_eval_counter + size(X, 1);
    end
end



