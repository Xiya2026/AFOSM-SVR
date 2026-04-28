function summary = clear_summary_relerr(summary)
fields = {"svm", "afosm", "ga"};
for i = 1:numel(fields)
    f = fields{i};
    if isfield(summary, f) && isstruct(summary.(f))
        summary.(f).rel_err_mean = NaN;
        summary.(f).rel_err_std = NaN;
    end
end
end


