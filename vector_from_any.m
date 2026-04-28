function vec = vector_from_any(x, nx)
vec = [];
if isempty(x)
    return;
end
if isnumeric(x) || islogical(x)
    xx = double(x(:)).';
    xx = xx(isfinite(xx));
    if isempty(xx)
        return;
    end
    if nargin >= 2 && ~isempty(nx) && numel(xx) >= nx
        vec = xx(end - nx + 1:end);
    else
        vec = xx;
    end
elseif iscell(x)
    for i = numel(x):-1:1
        vec = vector_from_any(x{i}, nx);
        if ~isempty(vec)
            return;
        end
    end
elseif ischar(x) || isstring(x)
    nums = sscanf(strrep(char(x), ',', ' '), '%f');
    nums = nums(isfinite(nums));
    if ~isempty(nums)
        nums = nums(:).';
        if nargin >= 2 && ~isempty(nx) && numel(nums) >= nx
            vec = nums(end - nx + 1:end);
        else
            vec = nums;
        end
    end
end
end


