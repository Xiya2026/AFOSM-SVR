function u0 = make_initial_u_samples(cfg, nx)
n0 = cfg.n_init;
b = cfg.u_init_bound;
n_anchor = min(4, n0);
n_lhs = n0 - n_anchor;

if n_lhs > 0
    u_lhs = -b + 2 * b * lhsdesign(n_lhs, nx);
else
    u_lhs = zeros(0, nx);
end

if nx == 2
    r = 0.8 * b;
    anchors = [0, r; 0, -r; r, 0; -r, 0];
else
    dirs = randn(max(n_anchor, 4), nx);
    dirs = dirs ./ max(vecnorm(dirs, 2, 2), 1e-12);
    anchors = 0.8 * b * dirs(1:n_anchor, :);
end

if n_anchor > 0
    u0 = [u_lhs; anchors(1:n_anchor, :)];
else
    u0 = u_lhs;
end
end


