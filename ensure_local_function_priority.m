function ensure_local_function_priority()
this_dir = fileparts(mfilename("fullpath"));
if ~isempty(this_dir) && exist(this_dir, "dir") == 7
    addpath(this_dir, "-begin");
end
end


