function [u_star, beta_uq, ok, msg] = solve_svr_form_ihlrf(prob, cfg, model, u_start)
% solve_svr_form_ihlrf: Helper function in the AFOSM-SVR modular workflow.
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
    if isempty(res)
        error("UQLab FORM returned empty Results.");
    end
    if (isstruct(res) || isobject(res)) && numel(res) > 1
        res = res(end);
    end

    [beta_named, pf_named, u_named, x_named, ~] = extract_uqlab_named_results(res, nx);
    if ~isfinite(beta_uq) && isfinite(beta_named)
        beta_uq = beta_named;
    end
    if ~isempty(u_named)
        u_star = u_named;
    elseif ~isempty(x_named)
        % FORM is solved directly in standard normal U-space here.
        u_star = x_named;
    end

    if ~isfinite(beta_uq)
        beta_uq = extract_struct_numeric_scalar(res, ...
            {"betahl", "beta_hl", "betaform", "reliabilityindex", "beta"});
    end
    if isempty(u_star)
        u_star = extract_struct_numeric_vector(res, ...
            {"ustar", "udesignpoint", "udesign", "designpointu", "u_star", ...
             "umpp", "u_mpp", "mppu"}, nx);
    end
    if isempty(u_star)
        x_star = extract_struct_numeric_vector(res, ...
            {"xstar", "xdesignpoint", "xdesign", "designpointx", "x_star", ...
             "xmpp", "x_mpp", "mppx"}, nx);
        if ~isempty(x_star)
            u_star = x_star;
        end
    end

    if isempty(u_star) || any(~isfinite(u_star))
        hist = get_container_fieldvalue_ci(res, "History");
        if ~isempty(hist)
            u_hist = extract_struct_numeric_vector(hist, ...
                {"ustar", "udesignpoint", "udesign", "designpointu", "u_star", ...
                 "u", "umpp", "u_mpp", "mppu"}, nx);
            if isempty(u_hist)
                x_hist = extract_struct_numeric_vector(hist, ...
                    {"xstar", "xdesignpoint", "xdesign", "designpointx", "x_star", ...
                     "x", "xmpp", "x_mpp", "mppx"}, nx);
                u_hist = x_hist;
            end
            if ~isempty(u_hist) && all(isfinite(u_hist))
                u_star = u_hist;
            end
        end
    end

    if (isempty(u_star) || any(~isfinite(u_star))) && isfinite(beta_uq)
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

    if isempty(u_star) || any(~isfinite(u_star))
        [beta_txt, pf_txt, u_txt, x_txt] = parse_uqlab_report_text(myRel, nx);
        if ~isfinite(beta_uq) && isfinite(beta_txt)
            beta_uq = beta_txt;
        end
        if isempty(u_star)
            if ~isempty(u_txt)
                u_star = u_txt;
            elseif ~isempty(x_txt)
                u_star = x_txt;
            end
        end
        if ~isfinite(beta_uq) && isfinite(pf_txt) && pf_txt > 0 && pf_txt < 1
            beta_uq = -norminv(clamp01(pf_txt));
        end
    end

    if ~isempty(u_star) && all(isfinite(u_star))
        u_star = reshape(u_star, 1, []);
        if numel(u_star) > nx
            u_star = u_star(1:nx);
        end
    end
    if isempty(u_star) || any(~isfinite(u_star))
        dbg = summarize_uqlab_analysis_object(myRel);
        error("UQLab FORM did not provide a valid U-space design point.%s", char(string(dbg)));
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



