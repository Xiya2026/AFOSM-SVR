function tf = is_valid_uqlab_root(root_path)
% is_valid_uqlab_root: Helper function in the AFOSM-SVR modular workflow.
if strlength(root_path) == 0
    tf = false;
    return;
end
r = char(root_path);
has_core = (exist(fullfile(r, "core", "uqlab.m"), "file") == 2) || ...
    (exist(fullfile(r, "core", "uqlab.p"), "file") == 6);
has_modules = exist(fullfile(r, "modules"), "dir") == 7;
has_model_mod = exist(fullfile(r, "modules", "uq_model"), "dir") == 7;
tf = has_core && has_modules && has_model_mod;
end



