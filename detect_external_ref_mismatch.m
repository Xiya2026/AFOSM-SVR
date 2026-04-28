function [is_mismatch, rel_diff_pct, anchor_pf, anchor_label] = detect_external_ref_mismatch(cfg, pf_mcs_ref, summary)
is_mismatch = false;
rel_diff_pct = NaN;
anchor_pf = NaN;
anchor_label = "N/A";

if ~logical(get_cfg_or(cfg, "external_ref_mismatch_check", true))
    return;
end
if ~isfield(cfg, "pf_ref_external")
    return;
end
pf_ext = cfg.pf_ref_external;
if ~(isnumeric(pf_ext) && isscalar(pf_ext) && isfinite(pf_ext) && pf_ext > 0)
    return;
end

if isfinite(pf_mcs_ref) && pf_mcs_ref > 0
    anchor_pf = pf_mcs_ref;
    anchor_label = "MCS";
else
    pool = [];
    labels = strings(0, 1);
    if isfield(summary, "svm") && isstruct(summary.svm) && isfield(summary.svm, "pf_mean") && isfinite(summary.svm.pf_mean) && summary.svm.pf_mean > 0
        pool(end + 1, 1) = summary.svm.pf_mean; %#ok<AGROW>
        labels(end + 1, 1) = "AFOSM(DI)-SVR"; %#ok<AGROW>
    end
    if isfield(summary, "afosm") && isstruct(summary.afosm) && isfield(summary.afosm, "pf_mean") && isfinite(summary.afosm.pf_mean) && summary.afosm.pf_mean > 0
        pool(end + 1, 1) = summary.afosm.pf_mean; %#ok<AGROW>
        labels(end + 1, 1) = "AFOSM(DI)"; %#ok<AGROW>
    end
    if isfield(summary, "ga") && isstruct(summary.ga) && isfield(summary.ga, "pf_mean") && isfinite(summary.ga.pf_mean) && summary.ga.pf_mean > 0
        pool(end + 1, 1) = summary.ga.pf_mean; %#ok<AGROW>
        labels(end + 1, 1) = "GA"; %#ok<AGROW>
    end
    if isempty(pool)
        return;
    end
    anchor_pf = median(pool, "omitnan");
    anchor_label = "methods-median";
end

if ~(isfinite(anchor_pf) && anchor_pf > 0)
    return;
end
rel_diff_pct = abs(pf_ext - anchor_pf) / max(anchor_pf, eps) * 100;
tol_pct = get_cfg_or(cfg, "external_ref_mismatch_tol_pct", 50.0);
is_mismatch = isfinite(rel_diff_pct) && (rel_diff_pct > tol_pct);
end


