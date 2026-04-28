function out = afosm_classic(prob, cfg)
% afosm_classic: Unified entry for classic AFOSM baselines.
afosm_backend = lower(string(get_cfg_or(cfg, "afosm_backend", "classic")));
if get_cfg_or(cfg, "require_uqlab_afosm", false) && ~strcmp(afosm_backend, "uqlab")
    error("AFOSM must use UQLab (require_uqlab_afosm=true), but afosm_backend='%s'.", afosm_backend);
end

if strcmp(afosm_backend, "uqlab")
    out = afosm_classic_uqlab(prob, cfg);
    % UQLab may only return final design point; add DI curve for plotting if needed.
    if (~isfield(out, "u_hist")) || isempty(out.u_hist) || size(out.u_hist, 1) <= 1
        out_di = afosm_classic_di(prob, cfg);
        if isfield(out_di, "u_hist") && ~isempty(out_di.u_hist) && size(out_di.u_hist, 1) > 1
            out.u_hist_curve = out_di.u_hist;
            out.beta_hist_curve = out_di.beta_hist;
            out.curve_trace_source = "internal_di";
        end
    end
    return;
end

out = afosm_classic_di(prob, cfg);
out.u_hist_curve = out.u_hist;
out.beta_hist_curve = out.beta_hist;
out.curve_trace_source = "afosm_backend";
end
