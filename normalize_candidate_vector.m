function vv = normalize_candidate_vector(v, nx)
% normalize_candidate_vector: Helper function in the AFOSM-SVR modular workflow.
if isvector(v)
    vv = reshape(v, 1, []);
    if ~isempty(nx) && numel(vv) > nx
        vv = vv(end - nx + 1:end);
    end
else
    [r, c] = size(v);
    if ~isempty(nx) && (c == nx)
        vv = reshape(v(end, :), 1, []);
    elseif ~isempty(nx) && (r == nx)
        vv = reshape(v(:, end), 1, []);
    else
        vv = reshape(v(end, :), 1, []);
    end
end

if ~isempty(nx) && numel(vv) > nx
    vv = vv(end - nx + 1:end);
end
end



