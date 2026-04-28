function [pf_svm, cov_svm, ncall_svm, u_svm, beta_svm] = afosm_svr_entry(prob, cfg)
% afosm_svr_entry: Core helper for AFOSM-SVR Example workflow.
base_args = {prob, cfg.Ntrain_initial, cfg.h_diff_svm, cfg.lambda, cfg.epsilon_svm, cfg.max_iter_svm};
try
    [pf_svm, cov_svm, ncall_svm, u_svm, beta_svm] = Main_AFOSM_SVM(base_args{:}, cfg);
catch ME
    msg = string(ME.message);
    id = lower(string(ME.identifier));
    if contains(id, "toomanyinputs") || contains(lower(msg), "too many input arguments")
        [pf_svm, cov_svm, ncall_svm, u_svm, beta_svm] = Main_AFOSM_SVM(base_args{:});
    else
        rethrow(ME);
    end
end
end

