function [mean_trace, std_trace, mat_trace] = aggregate_rel_error_traces(svm_runs)
% aggregate_rel_error_traces: Helper function in the AFOSM-SVR modular workflow.
n_runs = num_runs(svm_runs);
len_all = zeros(n_runs, 1);
for i = 1:n_runs
    run_i = get_run(svm_runs, i);
    len_all(i) = numel(run_i.trace.rel_err);
end

max_len = max(len_all);
if max_len < 1
    mean_trace = [];
    std_trace = [];
    mat_trace = [];
    return;
end

mat_trace = nan(n_runs, max_len);
for i = 1:n_runs
    run_i = get_run(svm_runs, i);
    this_trace = run_i.trace.rel_err(:).';
    mat_trace(i, 1:numel(this_trace)) = this_trace;
end

mean_trace = mean(mat_trace, 1, "omitnan");
std_trace = std(mat_trace, 0, 1, "omitnan");
end



