function grad = pf_central_diff_svr(model, u, h)
% pf_central_diff_svr: Helper function in the AFOSM-SVR modular workflow.
nx = numel(u);
grad = zeros(1, nx);
for i = 1:nx
    up = u;
    um = u;
    up(i) = up(i) + h;
    um(i) = um(i) - h;
    gp = predict_svr_model(model, up);
    gm = predict_svr_model(model, um);
    grad(i) = (gp - gm) / (2 * h);
end
end



