function v = regex_extract_scalar(txt, patterns)
% regex_extract_scalar: Helper function in the AFOSM-SVR modular workflow.
v = NaN;
for i = 1:numel(patterns)
    tok = regexp(txt, patterns{i}, 'tokens', 'once');
    if isempty(tok)
        continue;
    end
    t = str2double(tok{1});
    if isfinite(t)
        v = t;
        return;
    end
end
end



