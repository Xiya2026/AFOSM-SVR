function st = get_stage(stages, idx)
if ~(isscalar(idx) && isnumeric(idx) && isfinite(idx))
    error("get_stage: idx must be a finite numeric scalar.");
end
idx = round(idx);
n = num_runs(stages);
if idx < 1 || idx > n
    error("get_stage: idx=%d is out of range [1, %d].", idx, n);
end

if iscell(stages)
    st = stages{idx};
else
    st = stages(idx);
end

if isempty(st)
    error("get_stage: entry %d is empty.", idx);
end
end

