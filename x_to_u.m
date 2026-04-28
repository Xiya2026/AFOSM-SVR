function u = x_to_u(prob, x)
% x_to_u: Helper function in the AFOSM-SVR modular workflow.
if isvector(x)
    x = reshape(x, 1, []);
end
[n, nx] = size(x);
u = nan(n, nx);

for i = 1:nx
    dist_name = lower(prob.Dist{i});
    para = get_dist_para(prob, i);
    switch dist_name
        case {"norm", "normal"}
            u(:, i) = (x(:, i) - para(1)) ./ max(para(2), 1e-12);
        otherwise
            args = num2cell(para);
            p = cdf(prob.Dist{i}, x(:, i), args{:});
            p = min(max(p, 1e-12), 1 - 1e-12);
            u(:, i) = norminv(p);
    end
end
end



