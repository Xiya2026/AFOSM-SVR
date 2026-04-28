function vec = coerce_numeric_vector(v, nx)
% coerce_numeric_vector: Helper function in the AFOSM-SVR modular workflow.
vec = [];
if isempty(v)
    return;
end
if isnumeric(v) || islogical(v)
    vv = normalize_candidate_vector(double(v), nx);
    if ~isempty(vv) && all(isfinite(vv))
        vec = vv;
    end
    return;
end
if isstring(v) || ischar(v)
    nums = sscanf(strrep(char(v), ',', ' '), '%f');
    nums = nums(isfinite(nums));
    if ~isempty(nums)
        vv = normalize_candidate_vector(nums(:).', nx);
        if ~isempty(vv) && all(isfinite(vv))
            vec = vv;
        end
    end
    return;
end
if iscell(v)
    for i = numel(v):-1:1
        vec = coerce_numeric_vector(v{i}, nx);
        if ~isempty(vec)
            return;
        end
    end
    return;
end
vn = normalize_container_for_scan(v);
if ~(isstruct(vn) || isobject(vn))
    return;
end
prio = {"ustar","xstar","u","x","value","final","last","point","designpoint"};
for i = 1:numel(prio)
    tmp = get_container_fieldvalue_ci(vn, prio{i});
    vec = coerce_numeric_vector(tmp, nx);
    if ~isempty(vec)
        return;
    end
end
fn = get_container_fieldnames(vn);
for i = 1:numel(fn)
    tmp = get_container_fieldvalue(vn, fn{i});
    vec = coerce_numeric_vector(tmp, nx);
    if ~isempty(vec)
        return;
    end
end
end



