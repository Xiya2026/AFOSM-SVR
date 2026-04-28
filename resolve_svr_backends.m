function backends = resolve_svr_backends(cfg)
% resolve_svr_backends: Helper function in the AFOSM-SVR modular workflow.
primary = lower(strtrim(string(get_cfg_or(cfg, "svr_backend_primary", "uqlab"))));
if strlength(primary) == 0
    primary = "matlab";
end

if get_cfg_or(cfg, "enable_svr_backend_comparison", true)
    raw_backends = get_cfg_or(cfg, "svr_compare_backends", primary);
else
    raw_backends = primary;
end

if isstring(raw_backends) || ischar(raw_backends)
    backends = string(raw_backends);
elseif iscell(raw_backends)
    backends = string(raw_backends);
else
    backends = primary;
end

backends = lower(strtrim(backends(:).'));
backends(backends == "") = [];
if isempty(backends)
    backends = primary;
end

valid = ["matlab", "uqlab"];
for i = 1:numel(backends)
    if ~any(backends(i) == valid)
        error("Unsupported SVR backend '%s'. Supported values: matlab, uqlab.", backends(i));
    end
end

backends = unique(backends, "stable");
if ~any(backends == primary)
    backends = [primary, backends];
elseif backends(1) ~= primary
    backends = [primary, backends(backends ~= primary)];
end
backends = cellstr(backends);
end



