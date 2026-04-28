function fig_files = make_all_figures(prob, cfg, svm_runs, afosm_runs, ga_runs, ...
    trace_mean, trace_std, trace_matrix, summary, rep_idx, out_dir, labels)
% make_all_figures: Helper function in the AFOSM-SVR modular workflow.

if nargin < 12 || isempty(labels)
    labels = method_labels();
end

fig_files = struct();

fig_grid_n = max(60, round(get_cfg_or(cfg, "fig_grid_n", cfg.grid_n)));
fig_visible = char(string(get_cfg_or(cfg, "figure_visible", "off")));
if ~(strcmpi(fig_visible, "on") || strcmpi(fig_visible, "off"))
    fig_visible = 'off';
end
log_figure_timing = get_cfg_or(cfg, "log_figure_timing", false);

u1 = linspace(cfg.plot_u1(1), cfg.plot_u1(2), fig_grid_n);
u2 = linspace(cfg.plot_u2(1), cfg.plot_u2(2), fig_grid_n);
[U1, U2] = meshgrid(u1, u2);
ugrid = [U1(:), U2(:)];
G_true = reshape(eval_g_u(prob, ugrid), size(U1));

% Figure 1: average coordinate relative-error convergence (vs added sample count)
t_fig1 = tic;
fig1 = figure("Visible", fig_visible, "Color", "w", "Position", [80, 80, 760, 520]);
hold on;
u_ref = summary.ga.u_mean;
if any(~isfinite(u_ref))
    u_ref = summary.afosm.u_mean;
end
if any(~isfinite(u_ref))
    u_ref = summary.svm.u_mean;
end
[x_svm_add, mean_svm_x1, mean_svm_x2] = aggregate_u_coord_rel_error_by_iter(svm_runs, u_ref);
[x_af_add, mean_af_x1, mean_af_x2] = aggregate_u_coord_rel_error_by_iter(afosm_runs, u_ref);

h_svm_x1 = gobjects(0);
h_svm_x2 = gobjects(0);
h_af_x1 = gobjects(0);
h_af_x2 = gobjects(0);

if ~isempty(mean_svm_x1)
    h_svm_x1 = plot(x_svm_add, mean_svm_x1, "-o", ...
        "Color", [0.00, 0.35, 0.80], ...
        "MarkerFaceColor", [0.00, 0.35, 0.80], ...
        "MarkerSize", 5.0, "LineWidth", 1.6);
end
if ~isempty(mean_svm_x2)
    h_svm_x2 = plot(x_svm_add, mean_svm_x2, "-s", ...
        "Color", [0.85, 0.33, 0.10], ...
        "MarkerFaceColor", [0.85, 0.33, 0.10], ...
        "MarkerSize", 4.8, "LineWidth", 1.6);
end
if ~isempty(mean_af_x1)
    h_af_x1 = plot(x_af_add, mean_af_x1, "--^", ...
        "Color", [0.10, 0.58, 0.28], ...
        "MarkerFaceColor", [0.10, 0.58, 0.28], ...
        "MarkerSize", 5.0, "LineWidth", 1.6);
end
if ~isempty(mean_af_x2)
    h_af_x2 = plot(x_af_add, mean_af_x2, "--d", ...
        "Color", [0.75, 0.15, 0.15], ...
        "MarkerFaceColor", [0.75, 0.15, 0.15], ...
        "MarkerSize", 4.8, "LineWidth", 1.6);
end
if isempty(h_svm_x1)
    h_svm_x1 = plot(nan, nan, "-o", "Color", [0.00, 0.35, 0.80], "MarkerFaceColor", [0.00, 0.35, 0.80]);
end
if isempty(h_svm_x2)
    h_svm_x2 = plot(nan, nan, "-s", "Color", [0.85, 0.33, 0.10], "MarkerFaceColor", [0.85, 0.33, 0.10]);
end
if isempty(h_af_x1)
    h_af_x1 = plot(nan, nan, "--^", "Color", [0.10, 0.58, 0.28], "MarkerFaceColor", [0.10, 0.58, 0.28]);
end
if isempty(h_af_x2)
    h_af_x2 = plot(nan, nan, "--d", "Color", [0.75, 0.15, 0.15], "MarkerFaceColor", [0.75, 0.15, 0.15]);
end
grid on;
box on;
xlabel("Iteration");
ylabel("Average Relative Error (%)");
title(sprintf("Coordinate relative-error convergence vs added sample count (%d random runs)", numel(svm_runs)));
legend([h_svm_x1, h_svm_x2, h_af_x1, h_af_x2], ...
    {sprintf("%s rel.err(x_1)", labels.afosm_beta_equation), ...
     sprintf("%s rel.err(x_2)", labels.afosm_beta_equation), ...
     sprintf("%s rel.err(x_1)", labels.afosm_direct_iteration), ...
     sprintf("%s rel.err(x_2)", labels.afosm_direct_iteration)}, ...
    "Location", "northeast");
max_added_plot = max([x_svm_add(:); x_af_add(:); 1]);
if isfinite(max_added_plot) && max_added_plot >= 1
    xlim([1, max_added_plot]);
end

fig_files.fig1_png = fullfile(out_dir, "Fig1_AverageRelativeErrorCurve.png");
fig_files.fig1_pdf = fullfile(out_dir, "Fig1_AverageRelativeErrorCurve.pdf");
save_figure_outputs(fig1, fig_files.fig1_png, fig_files.fig1_pdf, cfg);
if log_figure_timing
    fprintf("Figure 1 export done in %.2fs\n", toc(t_fig1));
end

% Figure 2: final AFOSM-SVR stage plot (true vs SVR limit-state curves)
t_fig2 = tic;
rep = get_run(svm_runs, rep_idx);
n_stage = numel(rep.stages);
rep_backend = get_run_svr_backend(rep, cfg);
fig2 = figure("Visible", fig_visible, "Color", "w", "Position", [100, 100, 760, 620]);
if n_stage < 1
    st = struct("model", [], "S_u", rep.u_init, "u_design", rep.u_final, "iter", 0);
    model_rep = fit_svr_model(rep.u_init, rep.g_init, cfg, rep_backend);
    G_hat = reshape(predict_svr_model(model_rep, ugrid), size(U1));
else
    st = get_stage(rep.stages, n_stage);
    G_hat = reshape(predict_svr_model(st.model, ugrid), size(U1));
end

[~, h_true] = contour(U1, U2, G_true, [0, 0], "LineColor", [0.85, 0.20, 0.20], "LineWidth", 2.2);
hold on;
[~, h_hat] = contour(U1, U2, G_hat, [0, 0], "--", "LineColor", [0.05, 0.30, 0.80], "LineWidth", 2.0);

u_init = rep.u_init;
h_init = scatter(u_init(:, 1), u_init(:, 2), 42, [0.12, 0.12, 0.12], "filled", ...
    "MarkerFaceAlpha", 0.95, "MarkerEdgeColor", "none");

su = st.S_u;
root_all = zeros(0, 2);
if n_stage >= 2
    for ii = 2:n_stage
        st_i = get_stage(rep.stages, ii);
        if isfield(st_i, "root_u") && ~isempty(st_i.root_u)
            root_all = [root_all; st_i.root_u]; %#ok<AGROW>
        elseif isfield(st_i, "added_u") && ~isempty(st_i.added_u)
            root_all = [root_all; st_i.added_u]; %#ok<AGROW>
        end
    end
end
if ~isempty(root_all)
    root_all = unique(round(root_all, 8), "rows", "stable");
    h_root = scatter(root_all(:, 1), root_all(:, 2), 30, [0.65, 0.15, 0.85], "filled", ...
        "MarkerFaceAlpha", 0.82, "MarkerEdgeColor", [0.35, 0.05, 0.45], "MarkerEdgeAlpha", 0.88);
else
    h_root = scatter(nan, nan, 30, [0.65, 0.15, 0.85], "filled");
end

if n_stage >= 1 && st.iter > 0
    path_u = rep.u_hist(1:min(st.iter, size(rep.u_hist, 1)), :);
else
    path_u = zeros(0, 2);
end
if ~isempty(path_u)
    h_path = scatter(path_u(:, 1), path_u(:, 2), 34, [0.00, 0.55, 0.20], "filled");
    h_curr = scatter(path_u(end, 1), path_u(end, 2), 140, [0.95, 0.65, 0.10], "p", ...
        "filled", "MarkerEdgeColor", "k");
else
    h_path = scatter(nan, nan, 34, [0.00, 0.55, 0.20], "filled");
    h_curr = scatter(nan, nan, 140, [0.95, 0.65, 0.10], "p", "filled");
end
uistack(h_curr, "top");

axis equal;
if ~isempty(su)
    u_min = min(su, [], 1);
    u_max = max(su, [], 1);
    span = max(u_max - u_min, [1.2, 1.2]);
    cx = 0.5 * (u_min(1) + u_max(1));
    cy = 0.5 * (u_min(2) + u_max(2));
    xlim_local = [cx - 0.8 * span(1), cx + 0.8 * span(1)];
    ylim_local = [cy - 0.8 * span(2), cy + 0.8 * span(2)];
    xl = [max(xlim_local(1), cfg.plot_u1(1)), min(xlim_local(2), cfg.plot_u1(2))];
    yl = [max(ylim_local(1), cfg.plot_u2(1)), min(ylim_local(2), cfg.plot_u2(2))];
    if xl(1) >= xl(2)
        xl = cfg.plot_u1;
    end
    if yl(1) >= yl(2)
        yl = cfg.plot_u2;
    end
    xlim(xl);
    ylim(yl);
else
    xlim(cfg.plot_u1);
    ylim(cfg.plot_u2);
end
grid on;
box on;
xlabel("u_1");
ylabel("u_2");
if st.iter <= 0
    title(sprintf("Final stage (init only), N_{train} = %d", size(st.S_u, 1)));
else
    title(sprintf("Final iteration %d, N_{train} = %d", st.iter, size(st.S_u, 1)));
end

% No zoom inset in Figure 2 (per user preference).

legend([h_true, h_init, h_path, h_root, h_hat, h_curr], ...
    {"Actual LSF", "Initial DoE", ...
    sprintf("%s Process Points", labels.afosm_beta_equation), "Line Sampling Points", ...
    sprintf("SVR Prediction (%s)", upper(rep_backend)), sprintf("Design Point (%s)", labels.afosm_beta_equation)}, ...
    "Location", "northeast");

fig_files.fig2_png = fullfile(out_dir, "Fig2_StagedAddingPoints_TrueVsSVR.png");
fig_files.fig2_pdf = fullfile(out_dir, "Fig2_StagedAddingPoints_TrueVsSVR.pdf");
save_figure_outputs(fig2, fig_files.fig2_png, fig_files.fig2_pdf, cfg);
if log_figure_timing
    fprintf("Figure 2 export done in %.2fs\n", toc(t_fig2));
end

% Figure 3: final design-point comparison (AFOSM beta-equation vs AFOSM direct-iteration vs GA)
t_fig3 = tic;
n_runs = num_runs(svm_runs);
svm_u_all = zeros(n_runs, 2);
af_u_all = zeros(n_runs, 2);
ga_u_all = zeros(n_runs, 2);
for i = 1:n_runs
    svm_u_all(i, :) = get_run(svm_runs, i).u_final;
    af_u_all(i, :) = get_run(afosm_runs, i).u_final;
    ga_u_all(i, :) = get_run(ga_runs, i).u_final;
end

fig3 = figure("Visible", fig_visible, "Color", "w", "Position", [120, 120, 760, 620]);
[~, h_true3] = contour(U1, U2, G_true, [0, 0], "LineColor", [0.8, 0.1, 0.1], "LineWidth", 2.2);
hold on;

rep_all_u = get_stage(rep.stages, max(1, n_stage)).S_u;
if size(rep_all_u, 1) > cfg.n_init
    rep_added = rep_all_u(cfg.n_init + 1:end, :);
else
    rep_added = zeros(0, 2);
end
if ~isempty(rep_added)
    h_added3 = scatter(rep_added(:, 1), rep_added(:, 2), 34, [0.70, 0.10, 0.85], "filled", ...
        "MarkerFaceAlpha", 0.90, "MarkerEdgeColor", [0.35, 0.00, 0.45], "MarkerEdgeAlpha", 0.95);
else
    h_added3 = scatter(nan, nan, 34, [0.70, 0.10, 0.85], "filled");
end

h_svm_runs = scatter(svm_u_all(:, 1), svm_u_all(:, 2), 46, [0.10, 0.45, 0.85], "filled", ...
    "MarkerFaceAlpha", 0.85, "MarkerEdgeColor", [0.02, 0.20, 0.45], "MarkerEdgeAlpha", 0.9);
% h_af_runs = scatter(af_u_all(:, 1), af_u_all(:, 2), 46, [0.90, 0.38, 0.18], "filled", ...
    % "MarkerFaceAlpha", 0.85, "MarkerEdgeColor", [0.45, 0.15, 0.05], "MarkerEdgeAlpha", 0.9);

rep_svm_u = get_run(svm_runs, rep_idx).u_final;
rep_af_u = get_run(afosm_runs, rep_idx).u_final;
rep_ga_u = get_run(ga_runs, rep_idx).u_final;
h_rep_svm = plot(rep_svm_u(1), rep_svm_u(2), "d", "MarkerSize", 11, ...
    "MarkerFaceColor", [0.10, 0.45, 0.85], "MarkerEdgeColor", "k");
h_rep_af = plot(rep_af_u(1), rep_af_u(2), "s", "MarkerSize", 10, ...
    "MarkerFaceColor", [0.85, 0.35, 0.20], "MarkerEdgeColor", "k");
h_rep_ga = plot(rep_ga_u(1), rep_ga_u(2), "^", "MarkerSize", 10, ...
    "MarkerFaceColor", [0.15, 0.65, 0.25], "MarkerEdgeColor", "k");
h_origin = plot(0, 0, "ko", "MarkerFaceColor", "k", "MarkerSize", 6);

axis equal;
xlim(cfg.plot_u1);
ylim(cfg.plot_u2);
grid on;
box on;
xlabel("u_1");
ylabel("u_2");
title(sprintf("Design point comparison: %s vs %s vs GA", ...
    labels.afosm_beta_equation, labels.afosm_direct_iteration));

% No zoom inset in Figure 3 (per user preference).

legend([h_true3, h_added3, h_svm_runs, h_rep_svm, h_rep_af, h_rep_ga, h_origin], ...
    {"Actual LSF", sprintf("%s Process Points", labels.afosm_beta_equation), ...
    sprintf("Intermediate Process Points (%s)", labels.afosm_beta_equation),  ...
    sprintf("Design Point (%s)", labels.afosm_beta_equation), sprintf("Design Point (%s)", labels.afosm_direct_iteration), "Design Point (GA)", ...
    "Origin"}, "Location", "northeast");

fig_files.fig3_png = fullfile(out_dir, "Fig3_DesignPointComparison.png");
fig_files.fig3_pdf = fullfile(out_dir, "Fig3_DesignPointComparison.pdf");
save_figure_outputs(fig3, fig_files.fig3_png, fig_files.fig3_pdf, cfg);
if log_figure_timing
    fprintf("Figure 3 export done in %.2fs\n", toc(t_fig3));
end
end





