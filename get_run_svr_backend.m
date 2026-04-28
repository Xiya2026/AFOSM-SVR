function backend = get_run_svr_backend(run_struct, cfg)
% get_run_svr_backend: Helper function in the AFOSM-SVR modular workflow.
backend = lower(string(get_cfg_or(cfg, "svr_backend_primary", "uqlab")));
if isfield(run_struct, "svr_backend") && ~isempty(run_struct.svr_backend)
    backend = lower(string(run_struct.svr_backend));
end
backend = char(backend);
end



