function root_path = candidate_root_from_uqlab_file(uq_file)
root_path = "";
if nargin < 1 || isempty(uq_file)
    return;
end
uq_file = string(uq_file);
uq_file = strtrim(uq_file);
if strlength(uq_file) == 0
    return;
end
[p, f, ~] = fileparts(char(uq_file));
if strcmpi(f, "uqlab")
    if endsWith(string(p), string(filesep) + "core")
        root_path = string(fileparts(p));
    else
        root_path = string(p);
    end
end
end


