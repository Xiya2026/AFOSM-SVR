function vec = extract_struct_numeric_vector(s, candidates, nx)
% extract_struct_numeric_vector: Helper function in the AFOSM-SVR modular workflow.
vec = [];
if isempty(s)
    return;
end
if nargin < 3
    nx = [];
end

s = normalize_container_for_scan(s);

if iscell(s)
    for i = 1:numel(s)
        vec = extract_struct_numeric_vector(s{i}, candidates, nx);
        if ~isempty(vec)
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
        vv = coerce_numeric_vector(v, nx);
        if ~isempty(vv)
            vec = vv;
            return;
        end
    end
end

for i = 1:numel(fn)
    v = get_container_fieldvalue(s, fn{i});
    if isstruct(v) || isobject(v) || iscell(v)
        vec = extract_struct_numeric_vector(v, candidates, nx);
        if ~isempty(vec)
            return;
        end
    end
end
end



