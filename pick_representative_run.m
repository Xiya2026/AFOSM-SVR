function rep_idx = pick_representative_run(svm_runs, pf_ref)
n = num_runs(svm_runs);
err = zeros(n, 1);
for i = 1:n
    run_i = get_run(svm_runs, i);
    pf_i = get_pf_for_error(run_i);
    err(i) = abs(pf_i - pf_ref) / max(pf_ref, eps);
end
[~, order] = sort(err, "ascend");
rep_idx = order(max(1, ceil(n / 2)));
end


