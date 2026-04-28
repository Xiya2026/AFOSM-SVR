function x = u_to_x(prob, u)
% u_to_x: Helper function in the AFOSM-SVR modular workflow.
[n, nx] = size(u);
x = zeros(n, nx);

for i = 1:nx
    dist_name = lower(prob.Dist{i});
    para = get_dist_para(prob, i);
    switch dist_name
        case {"norm", "normal"}
            x(:, i) = para(1) + para(2) .* u(:, i);
        otherwise
            p = normcdf(u(:, i));
            p = min(max(p, 1e-12), 1 - 1e-12);
            args = num2cell(para);
            x(:, i) = icdf(prob.Dist{i}, p, args{:});
    end
end
end



