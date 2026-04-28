function state = ensure_uqlab_svr_ready(cfg)
persistent uq_is_initialized uq_qp_solver;

if isempty(uq_is_initialized) || ~uq_is_initialized
    force_uqlab_reinitialize(cfg);
    uq_is_initialized = true;

    qp_cfg = upper(strtrim(string(get_cfg_or(cfg, "uqlab_qpsolver", "auto"))));
    if strcmp(qp_cfg, "AUTO")
        uq_qp_solver = "SMO";
        if exist("fitrsvm", "file") ~= 2
            warning(["SMO is not available on this Matlab version. ", ...
                "UQLab SVR will use interior-point QP solver (IP)."]);
            uq_qp_solver = "IP";
        end
    else
        if ~(strcmp(qp_cfg, "SMO") || strcmp(qp_cfg, "IP"))
            error("uqlab_qpsolver must be 'auto', 'SMO', or 'IP'.");
        end
        uq_qp_solver = char(qp_cfg);
    end
end

state = struct("qp_solver", char(uq_qp_solver));
end


