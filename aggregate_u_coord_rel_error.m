function [x_added, mean_err_x1, mean_err_x2, mat_err_x1, mat_err_x2] = aggregate_u_coord_rel_error(svm_runs, u_ref)
% aggregate_u_coord_rel_error: Helper function in the AFOSM-SVR modular workflow.
n_runs = num_runs(svm_runs);
len_all = zeros(n_runs, 1);
for i = 1:n_runs
    run_i = get_run(svm_runs, i);
    if isfield(run_i, "stages") && ~isempty(run_i.stages)
        st_last = get_stage(run_i.stages, numel(run_i.stages));
        if isfield(st_last, "S_u") && ~isempty(st_last.S_u) && isfield(run_i, "u_init")
            len_all(i) = max(0, size(st_last.S_u, 1) - size(run_i.u_init, 1));
        end
    end
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
    run_i = get_run(svm_runs, i);
    if ~(isfield(run_i, "u_hist") && ~isempty(run_i.u_hist) && isfield(run_i, "stages"))
        continue;
    end
    uh = run_i.u_hist;
    n_i = min(size(uh, 1), max(0, numel(run_i.stages) - 1));
    if n_i < 1
        continue;
    end
    prev_add = 0;
    for k = 1:n_i
        st_k = get_stage(run_i.stages, k + 1);
        if ~(isfield(st_k, "S_u") && ~isempty(st_k.S_u) && isfield(run_i, "u_init"))
            continue;
        end
        cur_add = max(0, size(st_k.S_u, 1) - size(run_i.u_init, 1));
        if cur_add < 1
            continue;
        end
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



