function c = cellstr_from_which_result(w)
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


