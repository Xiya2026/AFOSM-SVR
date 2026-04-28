function v = get_container_fieldvalue(s, name)
% get_container_fieldvalue: Helper function in the AFOSM-SVR modular workflow.
v = [];
if isstruct(s) && numel(s) > 1
    try
        tmp = {s.(name)};
        if ~isempty(tmp)
            v = tmp{end};
            return;
        end
    catch
        v = [];
    end
end
if isobject(s) && numel(s) > 1
    try
        v = s(end).(name);
        return;
    catch
        v = [];
    end
end
try
    v = s.(name);
catch
    v = [];
end
end



