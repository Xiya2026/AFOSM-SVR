function r = get_run(runs, idx)
if ~(isscalar(idx) && isnumeric(idx) && isfinite(idx))
    error("get_run: idx must be a finite numeric scalar.");
end
idx = round(idx);
n = num_runs(runs);
if idx < 1 || idx > n
    error("get_run: idx=%d is out of range [1, %d].", idx, n);
end

if iscell(runs)
    r = runs{idx};
else
    r = runs(idx);
end

if isempty(r)
    error("get_run: entry %d is empty.", idx);
end
end


