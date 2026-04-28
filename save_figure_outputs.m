function save_figure_outputs(fig_handle, png_path, pdf_path, cfg)
% save_figure_outputs: Helper function in the AFOSM-SVR modular workflow.
% Robust export with fallback for MATLAB graphics compatibility.

if isgraphics(fig_handle, "figure")
    fig_obj = fig_handle;
elseif isgraphics(fig_handle)
    fig_obj = ancestor(fig_handle, "figure");
else
    error("save_figure_outputs:InvalidHandle", ...
        "Input is not a valid graphics handle for export.");
end
if isempty(fig_obj) || ~isgraphics(fig_obj, "figure")
    error("save_figure_outputs:NoFigure", ...
        "Cannot resolve a valid figure object from the input handle.");
end

drawnow;

do_png = get_cfg_or(cfg, "export_png", true);
do_pdf = get_cfg_or(cfg, "export_pdf", true);

if do_png
    png_dpi = max(120, round(get_cfg_or(cfg, "export_png_dpi", 300)));
    try
        exportgraphics(fig_obj, png_path, "Resolution", png_dpi);
    catch
        print(fig_obj, png_path, "-dpng", sprintf("-r%d", png_dpi));
    end
end

if do_pdf
    png_dpi = max(120, round(get_cfg_or(cfg, "export_png_dpi", 300)));
    pdf_dpi = max(120, round(get_cfg_or(cfg, "export_pdf_dpi", png_dpi)));
    if get_cfg_or(cfg, "export_pdf_vector", false)
        try
            exportgraphics(fig_obj, pdf_path, "ContentType", "vector");
        catch
            print(fig_obj, pdf_path, "-dpdf", "-painters");
        end
    else
        try
            exportgraphics(fig_obj, pdf_path, "ContentType", "image", "Resolution", pdf_dpi);
        catch
            print(fig_obj, pdf_path, "-dpdf", sprintf("-r%d", pdf_dpi), "-opengl");
        end
    end
end

try
    if get_cfg_or(cfg, "close_figure_after_export", false)
        close(fig_obj);
    end
catch
end
end
