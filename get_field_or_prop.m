function val = get_field_or_prop(s, name)
val = [];
if isempty(s)
    return;
end
if isstruct(s)
    if isfield(s, name)
        val = s.(name);
    end
    return;
end
try
    val = s.(name);
    return;
catch
end
try
    p = properties(s);
    idx = find(strcmpi(p, name), 1);
    if ~isempty(idx)
        val = s.(p{idx});
    end
catch
end
end


