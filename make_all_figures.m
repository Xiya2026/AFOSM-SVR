function fig_files = make_all_figures(prob, cfg, svm_runs, afosm_runs, ga_runs, ...
    trace_mean, trace_std, trace_matrix, summary, rep_idx, out_dir, labels)
% make_all_figures: Core helper for AFOSM-SVR Example workflow.

fig_files = struct();
if nargin < 11 %#ok<*INUSD>
    out_dir = pwd;
end
if nargin < 12 || isempty(labels)
    labels = method_labels();
end
do_png = get_cfg_or(cfg, "export_png", true);
do_pdf = get_cfg_or(cfg, "export_pdf", true);

% Figure 1: AFOSM-SVR relative Pf error trace over hybrid iterations.
if ~isempty(trace_mean)
    fig1 = figure("Color", "w", "Position", [90, 90, 760, 500]);
    hold on;
    k = 1:numel(trace_mean);
    lo = max(trace_mean - trace_std, 0);
    hi = trace_mean + trace_std;
    fill([k, fliplr(k)], [lo, fliplr(hi)], [0.80, 0.89, 1.00], ...
        "EdgeColor", "none", "FaceAlpha", 0.5);
    plot(k, trace_mean, "-o", "Color", [0.08, 0.36, 0.75], ...
        "MarkerFaceColor", [0.08, 0.36, 0.75], "LineWidth", 1.8, "MarkerSize", 5);
    grid on;
    box on;
    xlabel(sprintf("%s iteration", labels.afosm_beta_equation));
    ylabel("Relative error of Pf (%)");
    title(sprintf("%s convergence trace (mean +/- std over runs)", labels.afosm_beta_equation));
    fig_files.fig1_png = fullfile(out_dir, "Fig1_AFOSMSVM_RelErrTrace.png");
    fig_files.fig1_pdf = fullfile(out_dir, "Fig1_AFOSMSVM_RelErrTrace.pdf");
    if do_png
        exportgraphics(fig1, fig_files.fig1_png, "Resolution", 600);
    end
    if do_pdf
        exportgraphics(fig1, fig_files.fig1_pdf, "ContentType", "vector");
    end
end

% Figure 2: method-wise Pf comparison with standard deviation bars.
fig2 = figure("Color", "w", "Position", [120, 120, 760, 500]);
hold on;
x = 1:3;
pf_mean = [summary.svm.pf_mean, summary.afosm.pf_mean, summary.ga.pf_mean];
pf_std = [summary.svm.pf_std, summary.afosm.pf_std, summary.ga.pf_std];
bar(x, pf_mean, 0.62, "FaceColor", [0.70, 0.84, 0.95], "EdgeColor", [0.20, 0.30, 0.45]);
errorbar(x, pf_mean, pf_std, "k.", "LineWidth", 1.3, "CapSize", 12);
yline(summary.reference_pf, "--", "Reference MCS", ...
    "Color", [0.85, 0.20, 0.20], "LineWidth", 1.5, ...
    "LabelVerticalAlignment", "bottom", "LabelHorizontalAlignment", "left");
set(gca, "XTick", x, "XTickLabel", {labels.afosm_beta_equation, labels.afosm_direct_iteration, labels.ga});
grid on;
box on;
ylabel("Pf (importance sampling)");
title(sprintf("Rotating disk Example 2: Pf comparison (%d runs)", numel(svm_runs)));
fig_files.fig2_png = fullfile(out_dir, "Fig2_MethodPfComparison.png");
fig_files.fig2_pdf = fullfile(out_dir, "Fig2_MethodPfComparison.pdf");
if do_png
    exportgraphics(fig2, fig_files.fig2_png, "Resolution", 600);
end
if do_pdf
    exportgraphics(fig2, fig_files.fig2_pdf, "ContentType", "vector");
end

% Figure 3: beta statistics across runs.
n_runs = num_runs(svm_runs);
beta_svm = zeros(n_runs, 1);
beta_af = zeros(n_runs, 1);
beta_ga = zeros(n_runs, 1);
for i = 1:n_runs
    beta_svm(i) = get_run(svm_runs, i).beta_final;
    beta_af(i) = get_run(afosm_runs, i).beta;
    beta_ga(i) = get_run(ga_runs, i).beta;
end

fig3 = figure("Color", "w", "Position", [140, 140, 760, 500]);
hold on;
h_svm = plot(1:n_runs, beta_svm, "-o", "Color", [0.10, 0.45, 0.85], ...
    "MarkerFaceColor", [0.10, 0.45, 0.85], "LineWidth", 1.5);
h_af = plot(1:n_runs, beta_af, "-s", "Color", [0.88, 0.35, 0.18], ...
    "MarkerFaceColor", [0.88, 0.35, 0.18], "LineWidth", 1.5);
h_ga = plot(1:n_runs, beta_ga, "-^", "Color", [0.18, 0.62, 0.25], ...
    "MarkerFaceColor", [0.18, 0.62, 0.25], "LineWidth", 1.5);
h_ref = gobjects(0);
if isfinite(summary.reference_beta)
    h_ref = yline(summary.reference_beta, "--", "Reference \beta", ...
        "Color", [0.35, 0.35, 0.35], "LineWidth", 1.3);
end
grid on;
box on;
xlabel("Run index");
ylabel("Reliability index \beta");
title("Design-point reliability index comparison");
if ~isempty(h_ref)
    legend([h_svm, h_af, h_ga, h_ref], {labels.afosm_beta_equation, labels.afosm_direct_iteration, labels.ga, "Reference"}, "Location", "best");
else
    legend([h_svm, h_af, h_ga], {labels.afosm_beta_equation, labels.afosm_direct_iteration, labels.ga}, "Location", "best");
end
fig_files.fig3_png = fullfile(out_dir, "Fig3_BetaComparisonAcrossRuns.png");
fig_files.fig3_pdf = fullfile(out_dir, "Fig3_BetaComparisonAcrossRuns.pdf");
if do_png
    exportgraphics(fig3, fig_files.fig3_png, "Resolution", 600);
end
if do_pdf
    exportgraphics(fig3, fig_files.fig3_pdf, "ContentType", "vector");
end
end


