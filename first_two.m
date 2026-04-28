function u2 = first_two(u)
% first_two: Helper function in the AFOSM-SVR modular workflow.
u2 = [NaN, NaN];
if isempty(u)
    return;
end
u = reshape(u, 1, []);
m = min(2, numel(u));
u2(1:m) = u(1:m);
end



