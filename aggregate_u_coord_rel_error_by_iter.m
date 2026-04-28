function [iter_idx, mean_err_x1, mean_err_x2, mat_err_x1, mat_err_x2] = aggregate_u_coord_rel_error_by_iter(runs, u_ref)
% aggregate_u_coord_rel_error_by_iter: Helper function in the AFOSM-SVR modular workflow.
n_runs = num_runs(runs);
len_all = zeros(n_runs, 1);
for i = 1:n_runs
    run_i = get_run(runs, i);
    uh = get_convergence_u_hist(run_i);
    if ~isempty(uh)
        len_all(i) = size(uh, 1);
    end
end

max_len = max(len_all);
if max_len < 1
    iter_idx = [];
    mean_err_x1 = [];
    mean_err_x2 = [];
    mat_err_x1 = [];
    mat_err_x2 = [];
    return;
end

mat_err_x1 = nan(n_runs, max_len);
mat_err_x2 = nan(n_runs, max_len);
d1 = max(abs(u_ref(1)), 1e-8);
d2 = max(abs(u_ref(2)), 1e-8);

for i = 1:n_runs
    run_i = get_run(runs, i);
    uh = get_convergence_u_hist(run_i);
    if isempty(uh)
        continue;
    end
    n_i = min(size(uh, 1), max_len);
    for k = 1:n_i
        mat_err_x1(i, k) = abs(uh(k, 1) - u_ref(1)) / d1 * 100;
        mat_err_x2(i, k) = abs(uh(k, 2) - u_ref(2)) / d2 * 100;
    end
end

iter_idx = 1:max_len;
mean_err_x1 = mean(mat_err_x1, 1, "omitnan");
mean_err_x2 = mean(mat_err_x2, 1, "omitnan");
end



