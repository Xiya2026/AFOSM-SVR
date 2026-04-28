function y = clamp01(x)
% clamp01: Helper function in the AFOSM-SVR modular workflow.
y = min(max(x, 1e-12), 1 - 1e-12);
end



