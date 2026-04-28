function [u_star, beta_uq, ok, msg] = solve_svr_form_ihlrf(prob, cfg, model, u_start)
ok = false;
msg = "";
u_star = [];
beta_uq = NaN;

try
    ensure_uqlab_svr_ready(cfg);
    nx = prob.Nx;

    % FORM in standard normal U-space over the SVR surrogate.
    InputOpts = struct();
    InputOpts.Marginals = repmat(struct(), 1, nx);
    for i = 1:nx
        InputOpts.Marginals(i).Name = sprintf('U%d', i);
        InputOpts.Marginals(i).Type = 'Gaussian';
        InputOpts.Marginals(i).Parameters = [0, 1];
    end
    myInput = uq_call_with_reinitialize(@() uq_createInput(InputOpts), cfg);

    ModelOpts = struct();
    ModelOpts.mHandle = @(X) predict_svr_model(model, X);
    ModelOpts.isVectorized = true;
    myModel = uq_call_with_reinitialize(@() uq_createModel(ModelOpts), cfg);

    RelOpts = struct();
    RelOpts.Type = 'Reliability';
    RelOpts.Method = char(string(get_cfg_or(cfg, "uqlab_afosm_method", "FORM")));
    RelOpts.FORM.Algorithm = char(string(get_cfg_or(cfg, "uqlab_afosm_algorithm", "iHLRF")));
    RelOpts.FORM.MaxIterations = max(10, round(get_cfg_or(cfg, "max_iter_svm", cfg.max_iter)));
    RelOpts.FORM.StopU = get_cfg_or(cfg, "conv_tol_svm", cfg.conv_tol);
    RelOpts.FORM.StopG = get_cfg_or(cfg, "root_accept_tol", 1e-6);
    if nargin >= 4 && ~isempty(u_start) && all(isfinite(u_start))
        RelOpts.FORM.StartingPoint = reshape(u_start, 1, []);
    end
    RelOpts.Model = myModel;
    RelOpts.Input = myInput;
    myRel = uq_call_with_reinitialize(@() uq_createAnalysis(RelOpts), cfg);

    [beta_uq, pf_uq, u_star, x_star] = extract_uqlab_form_basic(myRel, nx);
    if (isempty(u_star) || any(~isfinite(u_star))) && ~isempty(x_star) && all(isfinite(x_star))
        % FORM here is posed directly in standard normal U-space.
        u_star = x_star;
    end
    if (isempty(u_star) || any(~isfinite(u_star))) && isfinite(beta_uq)
        res = [];
        if isstruct(myRel) && isfield(myRel, "Results")
            res = myRel.Results;
        else
            try
                res = myRel.Results;
            catch
                res = [];
            end
        end
        alpha_uq = extract_struct_numeric_vector(res, ...
            {"alpha", "alphahl", "alpha_hl", "alphaform", "directioncosines", "importance"}, nx);
        if ~isempty(alpha_uq) && all(isfinite(alpha_uq))
            aa = reshape(alpha_uq, 1, []);
            aa = aa(1:min(nx, numel(aa)));
            na = norm(aa);
            if na > 1e-12
                aa = aa / na;
                u1 = abs(beta_uq) * aa;
                u2 = -abs(beta_uq) * aa;
                g1 = predict_svr_model(model, u1);
                g2 = predict_svr_model(model, u2);
                if abs(g1) <= abs(g2)
                    u_star = u1;
                else
                    u_star = u2;
                end
            end
        end
    end
    if (isempty(u_star) || any(~isfinite(u_star))) && isfinite(pf_uq) && pf_uq > 0 && pf_uq < 1
        beta_uq = -norminv(clamp01(pf_uq));
    end
    if isempty(u_star) || any(~isfinite(u_star))
        error("UQLab FORM did not provide a valid U-space design point.");
    end
    if ~isfinite(beta_uq)
        beta_uq = norm(u_star);
    end
    u_star = reshape(u_star, 1, []);
    ok = true;
catch ME
    if ~isempty(ME.stack)
        st = ME.stack(1);
        msg = sprintf("%s [id=%s @ %s:%d]", ME.message, ME.identifier, st.name, st.line);
    else
        msg = sprintf("%s [id=%s]", ME.message, ME.identifier);
    end
end
end


