function [beta_txt, pf_txt, u_txt, x_txt] = parse_uqlab_report_text(myRel, nx)
% parse_uqlab_report_text: Helper function in the AFOSM-SVR modular workflow.
beta_txt = NaN;
pf_txt = NaN;
u_txt = [];
x_txt = [];

try
    report = evalc('uq_print(myRel)');
catch
    report = "";
end
if strlength(string(report)) == 0
    return;
end

report = char(report);
beta_txt = regex_extract_scalar(report, { ...
    '(?im)^\s*beta[^=\n]*=\s*([+-]?\d*\.?\d+(?:[eE][+-]?\d+)?)', ...
    '(?im)^\s*reliability index[^=\n]*=\s*([+-]?\d*\.?\d+(?:[eE][+-]?\d+)?)'});
pf_txt = regex_extract_scalar(report, { ...
    '(?im)^\s*pf[^=\n]*=\s*([+-]?\d*\.?\d+(?:[eE][+-]?\d+)?)', ...
    '(?im)^\s*failure probability[^=\n]*=\s*([+-]?\d*\.?\d+(?:[eE][+-]?\d+)?)'});

u_txt = regex_extract_vector(report, { ...
    '(?im)^\s*u\*[^=\n]*=\s*\[([^\]]+)\]', ...
    '(?im)^\s*design point.*u[^=\n]*=\s*\[([^\]]+)\]'}, nx);
x_txt = regex_extract_vector(report, { ...
    '(?im)^\s*x\*[^=\n]*=\s*\[([^\]]+)\]', ...
    '(?im)^\s*design point.*x[^=\n]*=\s*\[([^\]]+)\]'}, nx);
end



