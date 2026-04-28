function cfg = merge_cfg(cfg, cfg_in)
fn = fieldnames(cfg_in);
for i = 1:numel(fn)
    cfg.(fn{i}) = cfg_in.(fn{i});
end
end


