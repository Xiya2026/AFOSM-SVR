function u_fix = row_u_fixed_dim(u, nx)
u_fix = nan(1, nx);
if isempty(u)
    return;
end
u = reshape(u, 1, []);
m = min(nx, numel(u));
u_fix(1:m) = u(1:m);
end


