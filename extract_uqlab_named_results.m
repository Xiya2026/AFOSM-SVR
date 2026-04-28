function [beta_uq, pf_uq, u_star, x_star, n_eval] = extract_uqlab_named_results(res, nx)
% extract_uqlab_named_results: Helper function in the AFOSM-SVR modular workflow.
beta_uq = NaN;
pf_uq = NaN;
u_star = [];
x_star = [];
n_eval = NaN;
if isempty(res)
    return;
end

resn = normalize_container_for_scan(res);
if isempty(resn) || ~(isstruct(resn) || isobject(resn))
    return;
end

v = get_container_fieldvalue_ci(resn, "BetaHL");
beta_uq = coerce_numeric_scalar(v);

v = get_container_fieldvalue_ci(resn, "Pf");
pf_uq = coerce_numeric_scalar(v);
if ~isfinite(pf_uq)
    v = get_container_fieldvalue_ci(resn, "PfHL");
    pf_uq = coerce_numeric_scalar(v);
end

v = get_container_fieldvalue_ci(resn, "Ustar");
u_star = coerce_numeric_vector(v, nx);

v = get_container_fieldvalue_ci(resn, "Xstar");
x_star = coerce_numeric_vector(v, nx);

v = get_container_fieldvalue_ci(resn, "ModelEvaluations");
n_eval = coerce_numeric_scalar(v);

if (~isfinite(beta_uq) || ~isfinite(pf_uq) || isempty(u_star) || isempty(x_star) || ~isfinite(n_eval))
    vh = get_container_fieldvalue_ci(resn, "History");
    beta_h = coerce_numeric_scalar(vh);
    pf_h = coerce_numeric_scalar(vh);
    u_h = coerce_numeric_vector(vh, nx);
    if ~isfinite(beta_uq) && isfinite(beta_h); beta_uq = beta_h; end
    if ~isfinite(pf_uq) && isfinite(pf_h); pf_uq = pf_h; end
    if isempty(u_star) && ~isempty(u_h); u_star = u_h; end
end
end



