function fn = get_container_fieldnames(s)
% get_container_fieldnames: Helper function in the AFOSM-SVR modular workflow.
fn = {};
if isstruct(s)
    fn = fieldnames(s);
elseif isobject(s)
    try
        fn = properties(s);
    catch
        fn = {};
    end
end
end



