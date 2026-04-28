function c = cellstr_from_which_result(w)
% cellstr_from_which_result: Helper function in the AFOSM-SVR modular workflow.
if iscell(w)
    c = w;
elseif isstring(w)
    c = cellstr(w);
elseif ischar(w)
    c = cellstr(w);
    c = c(~cellfun(@isempty, strtrim(c)));
else
    c = {};
end
end



