function [beta_uq, pf_uq, u_star, x_star, n_eval] = extract_uqlab_form_results(myRel, prob)
% extract_uqlab_form_results: Helper function in the AFOSM-SVR modular workflow.
beta_uq = NaN;
pf_uq = NaN;
u_star = [];
x_star = [];
n_eval = NaN;
nx = prob.Nx;

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

[beta_named, pf_named, u_named, x_named, neval_named] = extract_uqlab_named_results(res, nx);
if isfinite(beta_named); beta_uq = beta_named; end
if isfinite(pf_named); pf_uq = pf_named; end
if ~isempty(u_named); u_star = u_named; end
if ~isempty(x_named); x_star = x_named; end
if isfinite(neval_named); n_eval = neval_named; end

beta_uq = extract_struct_numeric_scalar(res, ...
    {"betahl", "beta_hl", "betaform", "reliabilityindex", "beta"});
pf_uq = extract_struct_numeric_scalar(res, ...
    {"pfhl", "pf_form", "pfform", "failureprobability", "pf"});

u_star = extract_struct_numeric_vector(res, ...
    {"ustar", "udesignpoint", "udesign", "designpointu", "u_star", "umpp", "u_mpp", "mppu"}, nx);
x_star = extract_struct_numeric_vector(res, ...
    {"xstar", "xdesignpoint", "xdesign", "designpointx", "x_star", "xmpp", "x_mpp", "mppx"}, nx);

alpha_uq = extract_struct_numeric_vector(res, ...
    {"alpha", "alphahl", "alpha_hl", "alphaform", "directioncosines"}, nx);

n_eval = extract_struct_numeric_scalar(res, ...
    {"nmodelevaluations", "modelcalls", "nfun", "ncall", "neval"});
if ~isfinite(n_eval)
    n_eval = extract_struct_numeric_scalar(myRel, ...
        {"nmodelevaluations", "modelcalls", "nfun", "ncall", "neval"});
end

if isfinite(beta_named); beta_uq = beta_named; end
if isfinite(pf_named); pf_uq = pf_named; end
if ~isempty(u_named); u_star = u_named; end
if ~isempty(x_named); x_star = x_named; end
if isfinite(neval_named); n_eval = neval_named; end

if ~isfinite(beta_uq) && ~isfinite(pf_uq) && isempty(u_star) && isempty(x_star)
    [beta_txt, pf_txt, u_txt, x_txt] = parse_uqlab_report_text(myRel, nx);
    if isfinite(beta_txt)
        beta_uq = beta_txt;
    end
    if isfinite(pf_txt)
        pf_uq = pf_txt;
    end
    if ~isempty(u_txt)
        u_star = u_txt;
    end
    if ~isempty(x_txt)
        x_star = x_txt;
    end
end

if ~isfinite(beta_uq) && ~isempty(u_star)
    beta_uq = norm(u_star);
end
if ~isfinite(pf_uq) && isfinite(beta_uq)
    pf_uq = normcdf(-abs(beta_uq));
end

if isempty(u_star) && ~isempty(x_star)
    u_star = x_to_u(prob, x_star);
end

if isempty(u_star) && isfinite(beta_uq) && ~isempty(alpha_uq)
    aa = reshape(alpha_uq, 1, []);
    aa = aa(1:min(nx, numel(aa)));
    na = norm(aa);
    if na > 1e-12
        aa = aa / na;
        u1 = abs(beta_uq) * aa;
        u2 = -abs(beta_uq) * aa;
        g1 = eval_g_u(prob, u1);
        g2 = eval_g_u(prob, u2);
        if abs(g1) <= abs(g2)
            u_star = u1;
        else
            u_star = u2;
        end
    end
end

if isfinite(pf_uq) && (pf_uq > 0) && (pf_uq < 1)
    beta_from_pf = -norminv(clamp01(pf_uq));
    if ~isfinite(beta_uq) || (abs(beta_uq) < 1e-6)
        beta_uq = beta_from_pf;
    elseif abs(abs(beta_uq) - beta_from_pf) > 0.8
        beta_uq = beta_from_pf;
    end
end
end



