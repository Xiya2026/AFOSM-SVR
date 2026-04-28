function mu = get_mu_vector(prob, nx)
mu = zeros(1, nx);
if isfield(prob, "mu") && numel(prob.mu) >= nx
    mu = reshape(prob.mu(1:nx), 1, []);
end
end


