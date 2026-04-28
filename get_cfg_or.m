function v = get_cfg_or(cfg, name, fallback)
if isfield(cfg, name) && ~isempty(cfg.(name))
    v = cfg.(name);
else
    v = fallback;
end
end


