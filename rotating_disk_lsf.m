function g = rotating_disk_lsf(x)
if isvector(x)
    x = reshape(x, 1, []);
end
if size(x, 2) < 6
    error("Rotating disk Example 2 requires 6 variables [alpha_m, S_u, omega, rho, R_o, R_i].");
end

alpha_m = x(:, 1);
S_u_ksi = x(:, 2);
omega_krpm = x(:, 3);
rho = x(:, 4);
R_o = x(:, 5);
R_i = x(:, 6);

% Unit consistency for Eq. (22):
% S_u in table is ksi -> convert to psi;
% omega is taken as krpm -> convert to rad/s.
S_u_psi = 1e3 .* S_u_ksi;
omega_rad = omega_krpm .* (1e3 * 2 * pi / 60);

num = 3 .* alpha_m .* S_u_psi .* (R_o - R_i);
den = rho .* (omega_rad.^2) .* (R_o.^3 - R_i.^3);
ratio = num ./ den;

invalid = (num <= 0) | (den <= 0) | ~isfinite(ratio);
ratio(invalid) = 0;

Mb = sqrt(ratio);
Mb(invalid) = -1e12;
g = Mb - 0.37473;
end


