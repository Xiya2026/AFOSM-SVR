function v = get_struct_or(s, key, default_value)
if nargin < 3
    default_value = [];
end
v = default_value;
if isstruct(s) && isfield(s, key)
    v_try = s.(key);
    if ~isempty(v_try)
        v = v_try;
    end
end
end


