function val = coerce_numeric_scalar(v)
% coerce_numeric_scalar: Helper function in the AFOSM-SVR modular workflow.
val = NaN;
if isempty(v)
    return;
end
if isnumeric(v) || islogical(v)
    vv = double(v(:));
    vv = vv(isfinite(vv));
    if ~isempty(vv)
        val = vv(end);
    end
    return;
end
if isstring(v) || ischar(v)
    nums = sscanf(strrep(char(v), ',', ' '), '%f');
    nums = nums(isfinite(nums));
    if ~isempty(nums)
        val = nums(end);
    end
    return;
end
if iscell(v)
    for i = numel(v):-1:1
        val = coerce_numeric_scalar(v{i});
        if isfinite(val)
            return;
        end
    end
    return;
end
vn = normalize_container_for_scan(v);
if ~(isstruct(vn) || isobject(vn))
    return;
end
fn = get_container_fieldnames(vn);
prio = {"value","final","last","betahl","beta","pf","ncall","modelcalls","modelevaluations"};
for i = 1:numel(prio)
    tmp = get_container_fieldvalue_ci(vn, prio{i});
    val = coerce_numeric_scalar(tmp);
    if isfinite(val)
        return;
    end
end
for i = 1:numel(fn)
    tmp = get_container_fieldvalue(vn, fn{i});
    val = coerce_numeric_scalar(tmp);
    if isfinite(val)
        return;
    end
end
end



