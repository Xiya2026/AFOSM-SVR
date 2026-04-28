function para = normalize_uqlab_dist_params(prob, idx)
if isfield(prob, "Para") && numel(prob.Para) >= idx && ~isempty(prob.Para{idx})
    para = double(reshape(prob.Para{idx}, 1, []));
    return;
end
if isfield(prob, "mu") && isfield(prob, "sd") && ...
        numel(prob.mu) >= idx && numel(prob.sd) >= idx
    para = [prob.mu(idx), prob.sd(idx)];
    return;
end
error("Missing distribution parameters for variable %d.", idx);
end


