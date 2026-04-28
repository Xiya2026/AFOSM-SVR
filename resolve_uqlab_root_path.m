function root_path = resolve_uqlab_root_path(cfg)
% resolve_uqlab_root_path: Helper function in the AFOSM-SVR modular workflow.
root_path = "";
candidates = strings(0, 1);

cfg_root = string(get_cfg_or(cfg, "uqlab_root_path", ""));
if strlength(strtrim(cfg_root)) > 0
    candidates(end + 1) = strtrim(cfg_root); %#ok<AGROW>
end

try
    candidates(end + 1) = string(uq_rootPath); %#ok<AGROW>
catch
end

uq_all = cellstr_from_which_result(which("uqlab", "-all"));
for i = 1:numel(uq_all)
    cand = candidate_root_from_uqlab_file(uq_all{i});
    if strlength(cand) > 0
        candidates(end + 1) = cand; %#ok<AGROW>
    end
end

default_guess = "D:\Applications\UQLab_Rel2.2.0\UQLab_Rel2.2.0";
candidates(end + 1) = default_guess; %#ok<AGROW>

for i = 1:numel(candidates)
    c = strtrim(candidates(i));
    if is_valid_uqlab_root(c)
        root_path = c;
        return;
    end
end
end



