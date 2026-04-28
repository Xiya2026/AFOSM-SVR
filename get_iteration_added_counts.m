function add_counts = get_iteration_added_counts(run_i, n_i)
% get_iteration_added_counts: Helper function in the AFOSM-SVR modular workflow.
if nargin < 2 || isempty(n_i) || n_i < 1
    add_counts = zeros(1, 0);
    return;
end

% Default: one newly added sample per iteration.
add_counts = ones(1, n_i);

if ~(isfield(run_i, "stages") && ~isempty(run_i.stages))
    return;
end

add_counts = zeros(1, n_i);
n_stage = numel(run_i.stages);

for k = 1:n_i
    if (k + 1) > n_stage
        add_counts(k) = 1;
        continue;
    end

    st_k = get_stage(run_i.stages, k + 1);
    if isfield(st_k, "added_u") && ~isempty(st_k.added_u)
        add_counts(k) = size(st_k.added_u, 1);
        continue;
    end

    n_prev = NaN;
    n_cur = NaN;
    if isfield(st_k, "S_u") && ~isempty(st_k.S_u)
        n_cur = size(st_k.S_u, 1);
    end

    if k == 1
        if isfield(run_i, "u_init") && ~isempty(run_i.u_init)
            n_prev = size(run_i.u_init, 1);
        else
            st0 = get_stage(run_i.stages, 1);
            if isfield(st0, "S_u") && ~isempty(st0.S_u)
                n_prev = size(st0.S_u, 1);
            end
        end
    else
        st_prev = get_stage(run_i.stages, k);
        if isfield(st_prev, "S_u") && ~isempty(st_prev.S_u)
            n_prev = size(st_prev.S_u, 1);
        end
    end

    if isfinite(n_cur) && isfinite(n_prev)
        add_counts(k) = max(0, n_cur - n_prev);
    else
        add_counts(k) = 1;
    end
end
end



