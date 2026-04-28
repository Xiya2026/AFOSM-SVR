function para = get_dist_para(prob, idx)
% get_dist_para: Helper function in the AFOSM-SVR modular workflow.
if isfield(prob, "Para") && numel(prob.Para) >= idx && ~isempty(prob.Para{idx})
    para = prob.Para{idx};
    return;
end

dist_name = lower(prob.Dist{idx});
switch dist_name
    case {"norm", "normal"}
        para = [prob.mu(idx), prob.sd(idx)];
    case {"exp", "rayl"}
        para = prob.mu(idx);
    otherwise
        error("Missing Prob.Para for distribution '%s' at index %d.", dist_name, idx);
end
end



