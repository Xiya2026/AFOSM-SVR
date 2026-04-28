function [x_added, mean_err_x1, mean_err_x2, mat_err_x1, mat_err_x2] = aggregate_u_coord_rel_error_by_added_count(runs, u_ref)
% aggregate_u_coord_rel_error_by_added_count: Helper function in the AFOSM-SVR modular workflow.
n_runs = num_runs(runs);
len_all = zeros(n_runs, 1);
for i = 1:n_runs
    run_i = get_run(runs, i);
    uh = get_convergence_u_hist(run_i);
    if isempty(uh)
        continue;
    end
    n_i = size(uh, 1);
    add_counts = get_iteration_added_counts(run_i, n_i);
    len_all(i) = sum(max(add_counts(:), 0));
end

max_len = max(len_all);
if max_len < 1
    x_added = [];
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
    n_i = size(uh, 1);
    add_counts = get_iteration_added_counts(run_i, n_i);
    n_i = min(n_i, numel(add_counts));
    prev_add = 0;
    for k = 1:n_i
        add_k = max(round(add_counts(k)), 0);
        if add_k < 1
            continue;
        end
        cur_add = prev_add + add_k;
        e1k = abs(uh(k, 1) - u_ref(1)) / d1 * 100;
        e2k = abs(uh(k, 2) - u_ref(2)) / d2 * 100;
        idx1 = max(prev_add + 1, 1);
        idx2 = min(cur_add, max_len);
        if idx2 >= idx1
            mat_err_x1(i, idx1:idx2) = e1k;
            mat_err_x2(i, idx1:idx2) = e2k;
        end
        prev_add = cur_add;
        if prev_add >= max_len
            break;
        end
    end
end

x_added = 1:max_len;
mean_err_x1 = mean(mat_err_x1, 1, "omitnan");
mean_err_x2 = mean(mat_err_x2, 1, "omitnan");
end



