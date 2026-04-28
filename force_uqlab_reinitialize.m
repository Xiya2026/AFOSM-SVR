function force_uqlab_reinitialize(cfg)
% force_uqlab_reinitialize: Helper function in the AFOSM-SVR modular workflow.
root_path = resolve_uqlab_root_path(cfg);
if strlength(root_path) == 0
    uq_all = which("uqlab", "-all");
    uq_all_str = strjoin(cellstr_from_which_result(uq_all), " | ");
    error("Unable to locate a valid UQLab root containing modules/uq_model. which('uqlab','-all')=%s", uq_all_str);
end

root_path = char(root_path);
core_dir = fullfile(root_path, "core");
lib_dir = fullfile(root_path, "lib");
modules_dir = fullfile(root_path, "modules");

addpath(root_path, "-begin");
addpath(core_dir, "-begin");

if exist(lib_dir, "dir") == 7
    addpath(genpath(lib_dir), "-begin");
end

if exist(modules_dir, "dir") == 7
    addpath(modules_dir, "-begin");
    d = dir(modules_dir);
    d = d([d.isdir]);
    for i = 1:numel(d)
        name_i = string(d(i).name);
        if startsWith(name_i, ".")
            continue;
        end
        addpath(genpath(fullfile(modules_dir, char(name_i))), "-begin");
    end
end

if get_cfg_or(cfg, "uqlab_debug_paths", false)
    fprintf("UQLab init root: %s\n", root_path);
    fprintf("which uqlab: %s\n", which("uqlab"));
end

uqlab;
end



