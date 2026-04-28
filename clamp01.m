function y = clamp01(x)
y = min(max(x, 1e-12), 1 - 1e-12);
end


