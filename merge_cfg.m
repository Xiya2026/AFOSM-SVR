function cfg = merge_cfg(cfg, cfg_in)
keys = fieldnames(cfg_in);
for i = 1:numel(keys)
    k = keys{i};
    v = cfg_in.(k);
    if isfield(cfg, k) && isstruct(cfg.(k)) && isstruct(v)
        cfg.(k) = merge_cfg(cfg.(k), v);
    else
        if ~isempty(v) % keep defaults when incoming value is empty
            cfg.(k) = v;
        end
    end
end
end


