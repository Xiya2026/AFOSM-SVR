function v = get_cfg_or(cfg, key, default_value)
if isstruct(cfg) && isfield(cfg, key)
    v_try = cfg.(key);
    if ~isempty(v_try)
        v = v_try;
        return;
    end
end
v = default_value;
end


