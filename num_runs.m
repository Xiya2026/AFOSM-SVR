function n = num_runs(runs)
if isempty(runs)
    n = 0;
    return;
end

if iscell(runs)
    filled = ~cellfun(@isempty, runs);
    if any(filled)
        n = find(filled, 1, "last");
    else
        n = 0;
    end
else
    n = numel(runs);
end
end


