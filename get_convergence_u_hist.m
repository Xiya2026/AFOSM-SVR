function uh = get_convergence_u_hist(run_i)
% get_convergence_u_hist: Helper function in the AFOSM-SVR modular workflow.
uh = [];
if isfield(run_i, "u_hist_curve") && ~isempty(run_i.u_hist_curve)
    uh = run_i.u_hist_curve;
elseif isfield(run_i, "u_hist") && ~isempty(run_i.u_hist)
    uh = run_i.u_hist;
end
if isempty(uh)
    return;
end
if isvector(uh)
    uh = reshape(uh, 1, []);
end
end



