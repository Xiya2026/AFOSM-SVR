function [beta_uq, pf_uq, u_star, n_eval] = extract_uqlab_form_basic(myRel, nx)
beta_uq = NaN;
pf_uq = NaN;
u_star = [];
n_eval = NaN;

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
    return;
end
if (isstruct(res) || isobject(res)) && numel(res) > 1
    res = res(end);
end

beta_raw = get_field_or_prop(res, "BetaHL");
if ~isempty(beta_raw)
    beta_uq = scalar_from_any(beta_raw);
end
pf_raw = get_field_or_prop(res, "Pf");
if isempty(pf_raw)
    pf_raw = get_field_or_prop(res, "PfHL");
end
if ~isempty(pf_raw)
    pf_uq = scalar_from_any(pf_raw);
end
u_raw = get_field_or_prop(res, "Ustar");
if ~isempty(u_raw)
    u_star = vector_from_any(u_raw, nx);
end
n_raw = get_field_or_prop(res, "ModelEvaluations");
if ~isempty(n_raw)
    n_eval = scalar_from_any(n_raw);
end
end


