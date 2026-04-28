function v = get_cfg_or(cfg, name, fallback)
% get_cfg_or: Helper function in the AFOSM-SVR modular workflow.
if isfield(cfg, name) && ~isempty(cfg.(name))
    v = cfg.(name);
else
    v = fallback;
end
end



