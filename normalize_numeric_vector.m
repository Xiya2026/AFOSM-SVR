function v = normalize_numeric_vector(v_in, v_default, n_expect, require_positive)
v = v_default;
if isnumeric(v_in)
    vv = reshape(v_in, 1, []);
    if numel(vv) == n_expect && all(isfinite(vv))
        if require_positive
            if all(vv > 0)
                v = vv;
            end
        else
            v = vv;
        end
    end
end
end


