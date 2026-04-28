function sigma = get_sigma_vector(prob, nx)
sigma = ones(1, nx);
if isfield(prob, "sd") && numel(prob.sd) >= nx
    sigma = reshape(prob.sd(1:nx), 1, []);
end
for i = 1:nx
    para = get_dist_para(prob, i);
    di = lower(prob.Dist{i});
    if (strcmp(di, "norm") || strcmp(di, "normal")) && numel(para) >= 2
        sigma(i) = para(2);
    end
end
sigma = max(abs(sigma), 1e-12);
end


