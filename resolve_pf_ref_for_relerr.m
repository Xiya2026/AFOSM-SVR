function [pf_ref, ref_label] = resolve_pf_ref_for_relerr(cfg, pf_mcs_ref)
if isfinite(pf_mcs_ref) && pf_mcs_ref > 0
    pf_ref = pf_mcs_ref;
    ref_label = "MCS";
    return;
end

pf_ref = NaN;
ref_label = "N/A";
if isfield(cfg, "pf_ref_external")
    pf_try = cfg.pf_ref_external;
    if isnumeric(pf_try) && isscalar(pf_try) && isfinite(pf_try) && pf_try > 0
        pf_ref = double(pf_try);
        if isfield(cfg, "pf_ref_label") && ~isempty(cfg.pf_ref_label)
            ref_label = string(cfg.pf_ref_label);
        else
            ref_label = "external";
        end
    end
end
end


