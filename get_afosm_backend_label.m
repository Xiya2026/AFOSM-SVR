function backend = get_afosm_backend_label(run_struct)
% get_afosm_backend_label: Helper function in the AFOSM-SVR modular workflow.
backend = "internal";
if isfield(run_struct, "afosm_backend") && ~isempty(run_struct.afosm_backend)
    backend = string(run_struct.afosm_backend);
end
backend = char(lower(backend));
end


