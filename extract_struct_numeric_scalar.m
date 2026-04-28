function val = extract_struct_numeric_scalar(s, candidates)
% extract_struct_numeric_scalar: Helper function in the AFOSM-SVR modular workflow.
val = NaN;
if isempty(s)
    return;
end

s = normalize_container_for_scan(s);

if iscell(s)
    for i = 1:numel(s)
        val = extract_struct_numeric_scalar(s{i}, candidates);
        if isfinite(val)
            return;
        end
    end
    return;
end

if ~(isstruct(s) || isobject(s))
    return;
end

fn = get_container_fieldnames(s);
for i = 1:numel(fn)
    key = lower(fn{i});
    v = get_container_fieldvalue(s, fn{i});
    if any(strcmp(key, candidates))
        v_num = coerce_numeric_scalar(v);
        if isfinite(v_num)
            val = v_num;
            return;
        end
    end
end

for i = 1:numel(fn)
    v = get_container_fieldvalue(s, fn{i});
    if isstruct(v) || isobject(v) || iscell(v)
        val = extract_struct_numeric_scalar(v, candidates);
        if isfinite(val)
            return;
        end
    end
end
end



