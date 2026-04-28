function vec = regex_extract_vector(txt, patterns, nx)
% regex_extract_vector: Helper function in the AFOSM-SVR modular workflow.
vec = [];
for i = 1:numel(patterns)
    tok = regexp(txt, patterns{i}, 'tokens', 'once');
    if isempty(tok)
        continue;
    end
    vec_str = strrep(tok{1}, ',', ' ');
    nums = sscanf(vec_str, '%f');
    if isempty(nums)
        continue;
    end
    nums = nums(:).';
    if nargin >= 3 && ~isempty(nx)
        if numel(nums) < nx
            continue;
        end
        nums = nums(1:nx);
    end
    if all(isfinite(nums))
        vec = nums;
        return;
    end
end
end



