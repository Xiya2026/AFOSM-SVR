function check_required_functions(cfg, backends)
if nargin < 2 || isempty(backends)
    backends = resolve_svr_backends(cfg);
end

required = {'lhsdesign', 'normcdf', 'norminv', 'icdf'};
if any(strcmpi(backends, 'matlab'))
    required{end + 1} = 'fitrsvm'; %#ok<AGROW>
end
if any(strcmpi(backends, 'uqlab'))
    required = [required, {'uqlab', 'uq_createModel', 'uq_evalModel'}]; %#ok<AGROW>
end
if strcmpi(string(get_cfg_or(cfg, "afosm_backend", "classic")), "uqlab")
    required = [required, {'uq_createInput', 'uq_createAnalysis'}]; %#ok<AGROW>
end
required = unique(required, "stable");
for i = 1:numel(required)
    if exist(required{i}, "file") ~= 2
        error("Required function '%s' not found. Please enable needed toolboxes.", required{i});
    end
end
end


