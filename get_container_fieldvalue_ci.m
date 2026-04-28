function v = get_container_fieldvalue_ci(s, target_name)
% get_container_fieldvalue_ci: Helper function in the AFOSM-SVR modular workflow.
v = [];
if isempty(s)
    return;
end
s = normalize_container_for_scan(s);
if isempty(s)
    return;
end
fn = get_container_fieldnames(s);
if isempty(fn)
    return;
end
idx = find(strcmpi(fn, char(target_name)), 1, "first");
if isempty(idx)
    return;
end
v = get_container_fieldvalue(s, fn{idx});
end



