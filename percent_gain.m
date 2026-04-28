function g = percent_gain(base_val, new_val)
if ~isfinite(base_val) || ~isfinite(new_val) || abs(base_val) <= eps
    g = NaN;
else
    g = (base_val - new_val) / base_val * 100;
end
end


