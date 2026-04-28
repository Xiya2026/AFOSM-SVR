function v = scalar_from_any(x)
v = NaN;
if isempty(x)
    return;
end
if isnumeric(x) || islogical(x)
    xx = double(x(:));
    xx = xx(isfinite(xx));
    if ~isempty(xx)
        v = xx(end);
    end
elseif iscell(x)
    for i = numel(x):-1:1
        v = scalar_from_any(x{i});
        if isfinite(v)
            return;
        end
    end
elseif ischar(x) || isstring(x)
    nums = sscanf(strrep(char(x), ',', ' '), '%f');
    nums = nums(isfinite(nums));
    if ~isempty(nums)
        v = nums(end);
    end
end
end


